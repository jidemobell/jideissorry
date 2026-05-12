import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { supabaseConfig } from "./supabase-config.js";

const ventInput = document.getElementById("vent-message");
const saveVentButton = document.getElementById("save-vent");
const saveVentLabel = saveVentButton.querySelector(".primary-label");
const charCount = document.getElementById("char-count");
const smileStatus = document.getElementById("smile-status");
const toast = document.getElementById("toast");

const emojiButtons = Array.from(document.querySelectorAll(".emoji"));
const selectedEmojis = new Set();

const maxChars = 500;
const visitorIdStorageKey = "imsorry-visitor-id";
const sessionOpenStorageKey = "imsorry-session-open";

const supabase = createSupabaseClient();
const visitorId = getVisitorId();
let locationInfo = null;
let toastTimer = null;
let ventDebounce = null;

initLocationAndOpen();

function createSupabaseClient() {
  if (!supabaseConfig.url || !supabaseConfig.anonKey) return null;
  return createClient(supabaseConfig.url, supabaseConfig.anonKey);
}

function getVisitorId() {
  const existing = localStorage.getItem(visitorIdStorageKey);
  if (existing) return existing;
  const next = crypto.randomUUID();
  localStorage.setItem(visitorIdStorageKey, next);
  return next;
}

function showToast(message) {
  toast.textContent = message;
  toast.hidden = false;
  void toast.offsetWidth;
  toast.classList.add("is-visible");
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    toast.classList.remove("is-visible");
    setTimeout(() => { toast.hidden = true; }, 250);
  }, 2200);
}

function updateCharCount() {
  if (ventInput.value.length > maxChars) {
    ventInput.value = ventInput.value.slice(0, maxChars);
  }
  charCount.textContent = String(ventInput.value.length);
}

function buildEventDetail(eventName) {
  switch (eventName) {
    case "vent-input":
      return `${ventInput.value.trim().length} characters entered`;
    case "vent-save":
      return ventInput.value.trim().slice(0, 500) || "Vent sealed";
    case "emoji-pick":
      return Array.from(selectedEmojis).join(" ") || "Emoji toggled";
    default:
      return null;
  }
}

async function logInteraction(eventName) {
  if (!supabase) return;
  try {
    await supabase.from("apology_interactions").insert({
      site_label: supabaseConfig.siteLabel,
      visitor_id: visitorId,
      event_name: eventName,
      event_detail: buildEventDetail(eventName),
      page_url: window.location.href,
      user_agent: navigator.userAgent,
      country: locationInfo?.country ?? null,
      region: locationInfo?.region ?? null,
      city: locationInfo?.city ?? null,
    });
  } catch {
    // Silent.
  }
}

async function initLocationAndOpen() {
  try {
    const response = await fetch("https://ipapi.co/json/");
    if (response.ok) {
      const data = await response.json();
      locationInfo = {
        country: data.country_name || data.country || null,
        region: data.region || null,
        city: data.city || null,
      };
    }
  } catch {
    // Ignore.
  }

  if (!sessionStorage.getItem(sessionOpenStorageKey)) {
    sessionStorage.setItem(sessionOpenStorageKey, "1");
    logInteraction("page-open");
  }
}

ventInput.addEventListener("input", () => {
  updateCharCount();
  clearTimeout(ventDebounce);
  ventDebounce = setTimeout(() => {
    logInteraction("vent-input");
  }, 600);
});

saveVentButton.addEventListener("click", () => {
  const text = ventInput.value.trim();
  if (!text) {
    ventInput.focus();
    showToast("Nothing to leave yet.");
    return;
  }
  logInteraction("vent-save");
  saveVentButton.classList.add("is-done");
  saveVentLabel.textContent = "Got it. Thank you.";
  showToast("Heard you.");
});

emojiButtons.forEach((button) => {
  button.addEventListener("click", () => {
    const emoji = button.dataset.emoji;
    if (!emoji) return;

    if (selectedEmojis.has(emoji)) {
      selectedEmojis.delete(emoji);
      button.classList.remove("is-selected");
      button.setAttribute("aria-pressed", "false");
    } else {
      selectedEmojis.add(emoji);
      button.classList.add("is-selected");
      button.setAttribute("aria-pressed", "true");
    }

    if (selectedEmojis.size > 0) {
      smileStatus.textContent = "received";
      smileStatus.classList.add("is-on");
      smileStatus.classList.remove("soft");
    } else {
      smileStatus.textContent = "optional";
      smileStatus.classList.remove("is-on");
      smileStatus.classList.add("soft");
    }

    logInteraction("emoji-pick");
  });
});

updateCharCount();
