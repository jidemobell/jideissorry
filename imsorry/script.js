import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { supabaseConfig } from "./supabase-config.js";

const ventInput = document.getElementById("vent-message");
const saveVentButton = document.getElementById("save-vent");
const charCount = document.getElementById("char-count");
const frequencySlider = document.getElementById("frequency-slider");
const frequencyValue = document.getElementById("frequency-value");
const receiptEngagement = document.getElementById("receipt-engagement");
const receiptRant = document.getElementById("receipt-rant");
const receiptEmoji = document.getElementById("receipt-emoji");
const receiptFrequency = document.getElementById("receipt-frequency");
const emojiSummary = document.getElementById("emoji-summary");
const emojiWarning = document.getElementById("emoji-warning");
const apologyNote = document.getElementById("apology-note");

const emojiButtons = Array.from(document.querySelectorAll(".emoji-button"));
const selectedEmojis = new Set();
const maxChars = 500;
const engagementStorageKey = "imsorry-engagement-state";
const visitorIdStorageKey = "imsorry-visitor-id";

const supabase = createSupabaseClient();
const visitorId = getVisitorId();

let engagementState = loadEngagementState();

function formatFrequency(value) {
  return value === 1 ? "Every day" : `Every ${value} days`;
}

function createSupabaseClient() {
  if (!supabaseConfig.url || !supabaseConfig.anonKey) {
    return null;
  }

  return createClient(supabaseConfig.url, supabaseConfig.anonKey);
}

function getVisitorId() {
  const existingId = localStorage.getItem(visitorIdStorageKey);
  if (existingId) {
    return existingId;
  }

  const nextId = crypto.randomUUID();
  localStorage.setItem(visitorIdStorageKey, nextId);
  return nextId;
}

function loadEngagementState() {
  try {
    const stored = localStorage.getItem(engagementStorageKey);
    return stored ? JSON.parse(stored) : null;
  } catch {
    return null;
  }
}

function saveEngagementState() {
  try {
    localStorage.setItem(engagementStorageKey, JSON.stringify(engagementState));
  } catch {
    // Ignore storage failures and keep the UI working.
  }
}

function formatEventName(eventName) {
  switch (eventName) {
    case "vent-input":
      return "typed in the vent window";
    case "vent-save":
      return "sealed the vent";
    case "emoji-pick":
      return "picked a smiley";
    case "frequency-change":
      return "changed the check-in slider";
    default:
      return "interacted";
  }
}

function formatTimestamp(timestamp) {
  if (!timestamp) {
    return "just now";
  }

  return new Date(timestamp).toLocaleString([], {
    dateStyle: "medium",
    timeStyle: "short",
  });
}

function renderEngagementState() {
  if (!engagementState) {
    receiptEngagement.textContent = "No sign yet";
    return;
  }

  receiptEngagement.textContent = `She ${formatEventName(engagementState.lastEvent)} on ${formatTimestamp(engagementState.lastAt)}`;
}

function registerInteraction(eventName) {
  const now = new Date().toISOString();

  engagementState = {
    firstEvent: engagementState?.firstEvent ?? eventName,
    firstAt: engagementState?.firstAt ?? now,
    lastEvent: eventName,
    lastAt: now,
  };

  saveEngagementState();
  renderEngagementState();
  logInteraction(eventName).catch(() => {});
}

async function logInteraction(eventName) {
  if (!supabase) {
    return;
  }

  const eventDetail = buildEventDetail(eventName);

  await supabase.from("apology_interactions").insert({
    site_label: supabaseConfig.siteLabel,
    visitor_id: visitorId,
    event_name: eventName,
    event_detail: eventDetail,
    page_url: window.location.href,
    user_agent: navigator.userAgent,
  });
}

function buildEventDetail(eventName) {
  switch (eventName) {
    case "vent-input":
      return `${ventInput.value.trim().length} characters entered`;
    case "vent-save":
      return "Vent sealed";
    case "emoji-pick":
      return Array.from(selectedEmojis).join(" ") || "Emoji toggled";
    case "frequency-change":
      return formatFrequency(Number(frequencySlider.value));
    default:
      return null;
  }
}

function updateCharCount() {
  const trimmed = ventInput.value.slice(0, maxChars);
  if (trimmed !== ventInput.value) {
    ventInput.value = trimmed;
  }
  charCount.textContent = `${ventInput.value.length} / ${maxChars}`;
  receiptRant.textContent = ventInput.value.trim()
    ? `She left ${ventInput.value.trim().length} characters in the vent box`
    : "She has not typed anything yet";
  buildApologyNote();
}

function updateFrequency() {
  const value = Number(frequencySlider.value);
  const label = formatFrequency(value);
  frequencyValue.textContent = label;
  receiptFrequency.textContent = label;
  buildApologyNote();
}

function updateEmojiState() {
  const picked = Array.from(selectedEmojis);
  const hasEmoji = picked.length > 0;

  emojiSummary.textContent = hasEmoji
    ? `Smiley evidence received: ${picked.join(" ")}`
    : "No smile detected yet.";
  receiptEmoji.textContent = hasEmoji ? `She picked ${picked.join(" ")}` : "No smiley picked yet";
  emojiWarning.textContent = hasEmoji ? "Smile received" : "Pick at least one";
  buildApologyNote();
}

function buildApologyNote() {
  const ventText = ventInput.value.trim();
  const picked = Array.from(selectedEmojis);
  const frequencyText = formatFrequency(Number(frequencySlider.value)).toLowerCase();

  if (!picked.length) {
    emojiWarning.textContent = "Pick at least one";
    emojiWarning.focus?.();
    apologyNote.textContent = "I need one smiley emoji before this apology note unlocks.";
    return;
  }

  const toneLine = ventText
    ? `I heard this clearly: "${ventText.slice(0, 120)}${ventText.length > 120 ? "..." : ""}".`
    : "I know there is hurt here even if you do not feel like typing it right now.";

  apologyNote.textContent = `${toneLine} I am not asking you to skip your anger. I am asking for a chance to keep showing up ${frequencyText}, with patience, accountability, and at least one remembered smile ${picked.join(" ")}.`;
}

ventInput.addEventListener("input", updateCharCount);
ventInput.addEventListener("input", () => {
  registerInteraction("vent-input");
});
saveVentButton.addEventListener("click", () => {
  registerInteraction("vent-save");
  updateCharCount();
  saveVentButton.textContent = "Vent sealed";
});

frequencySlider.addEventListener("input", () => {
  registerInteraction("frequency-change");
  updateFrequency();
});

emojiButtons.forEach((button) => {
  button.addEventListener("click", () => {
    const emoji = button.dataset.emoji;
    if (!emoji) {
      return;
    }

    if (selectedEmojis.has(emoji)) {
      selectedEmojis.delete(emoji);
      button.classList.remove("is-selected");
      button.setAttribute("aria-pressed", "false");
    } else {
      selectedEmojis.add(emoji);
      button.classList.add("is-selected");
      button.setAttribute("aria-pressed", "true");
    }

    registerInteraction("emoji-pick");
    updateEmojiState();
  });
});

updateCharCount();
updateFrequency();
updateEmojiState();
renderEngagementState();