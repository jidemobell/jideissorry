# Apple Developer Status - Quick Decision Tree

## START HERE: What Do You See When You Sign In?

**Go to [developer.apple.com](https://developer.apple.com) and sign in with your Apple ID**

---

```
┌─────────────────────────────────────────────────────────────┐
│  What appears after signing in to developer.apple.com?     │
└─────────────────────────────────────────────────────────────┘
                            │
                ┌───────────┴──────────┐
                │                      │
        ┌───────▼────────┐    ┌───────▼────────────┐
        │ "Join the      │    │  "Account" link    │
        │  Apple          │    │   is visible       │
        │  Developer      │    │                    │
        │  Program"       │    └────────────────────┘
        └────────────────┘             │
                │                      │
                │              ┌───────┴────────┐
        ✅ NOT ENROLLED        │                │
                │         ┌────▼─────┐   ┌─────▼──────┐
                │         │Shows:    │   │Shows:      │
                │         │"Account  │   │"Account    │
                │         │Holder:   │   │Holder:     │
                │         │YOUR NAME"│   │[COMPANY    │
                │         │          │   │ NAME]"     │
                │         └──────────┘   └────────────┘
                │              │               │
                │              │               │
        ┌───────▼──────────┐   │       ┌──────▼────────┐
        │                  │   │       │               │
        │ DECISION:        │   │       │ DECISION:     │
        │ Pay €99 to       │   │       │ You're on     │
        │ enroll           │   │       │ someone's     │
        │                  │   │       │ team (FREE!)  │
        │ Use for:         │   │       │               │
        │ - Finance app    │   │       │ Can develop   │
        │   testing        │   │       │ for THEIR     │
        │ - Learning       │   │       │ apps only     │
        │                  │   │       │               │
        │ Later: Enroll    │   │       │ Still need    │
        │ Atensai company  │   │       │ own account   │
        │ account (€99)    │   │       │ for personal  │
        │ for dating app   │   │       │ apps (€99)    │
        └──────────────────┘   │       └───────────────┘
                               │
                               │
                    ┌──────────▼──────────┐
                    │ Click "Account"     │
                    │ What's the status?  │
                    └─────────────────────┘
                               │
                  ┌────────────┴────────────┐
                  │                         │
         ┌────────▼─────────┐    ┌─────────▼─────────┐
         │ "Membership:     │    │ "Membership:      │
         │  ACTIVE"         │    │  EXPIRED"         │
         │                  │    │                   │
         │ "Renewal date:   │    │ "Renew Now"       │
         │  [Future Date]"  │    │  button           │
         └──────────────────┘    └───────────────────┘
                  │                         │
                  │                         │
         ✅ ALREADY ENROLLED       ⏰ WAS ENROLLED
                  │                         │
                  │                         │
         ┌────────▼─────────┐    ┌─────────▼──────────┐
         │                  │    │                    │
         │ DECISION:        │    │ DECISION:          │
         │ 🎉 USE IT NOW!   │    │ Check expiry date  │
         │                  │    │                    │
         │ - Upload finance │    │ Expired <90 days:  │
         │   app to         │    │   → Renew (€99)    │
         │   TestFlight     │    │                    │
         │   immediately    │    │ Expired >90 days:  │
         │                  │    │   → Re-enroll (€99)│
         │ - Check renewal  │    │                    │
         │   date, plan     │    │ Use renewed        │
         │   for €99        │    │ account for        │
         │   payment        │    │ finance app        │
         │                  │    │                    │
         │ - Still register │    │ Still register     │
         │   Atensai        │    │ Atensai company    │
         │   company later  │    │ account for dating │
         │   for dating app │    │ app (€99)          │
         └──────────────────┘    └────────────────────┘
```

---

## Quick Reference: What Each Status Means

### 1. "Join the Apple Developer Program" (Not Enrolled)
**Status:** ⭐ No active membership  
**Cost:** €99 to enroll  
**Action:** Read Apple_Dev_Strategy.md and follow hybrid approach  
**Timeline:** Can enroll today, active within hours  

---

### 2. "Account Holder: YOUR NAME" + "Membership: Active" (You Own It!)
**Status:** 🎉 You have active Individual membership  
**Cost:** €0 now (paid already), €99 at renewal date  
**Action:** 
- Use it RIGHT NOW for finance app testing
- Check renewal date (plan for €99 payment)
- Still register Atensai company (€99) for dating app later
**Timeline:** Upload finance app to TestFlight today!  

---

### 3. "Account Holder: [COMPANY NAME]" (Team Member)
**Status:** 👥 You're on someone's team  
**Cost:** €0 for this (they pay)  
**Action:**
- Keep team access for work projects
- Enroll SEPARATE Individual account (€99) for YOUR finance app
- Register Atensai company (€99) for dating app
**Timeline:** Need to enroll new account (can start today)  
**Total Cost:** €198/year (your Individual + Atensai company)  

---

### 4. "Membership: Expired" (Needs Renewal)
**Status:** ⏰ Previously enrolled, membership lapsed  
**Cost:** €99 to renew  
**Action:**
- If expired <90 days: Click "Renew" (€99, keeps history)
- If expired >90 days: Re-enroll as new (€99, fresh start)
- Use renewed account for finance app
- Register Atensai company (€99) for dating app later
**Timeline:** Renewal active within hours  

---

## Cost Impact on Your Strategy

### Scenario A: Not Enrolled (Start Fresh)
| Account Type | Purpose | Cost | When |
|-------------|---------|------|------|
| Individual | Finance app testing | €99/year | Now |
| Atensai Organization | Dating app commercial | €99/year | Month 3 |
| **TOTAL** | **Both apps covered** | **€198/year** | **Spread over 3 months** |

---

### Scenario B: You Have Active Individual Membership
| Account Type | Purpose | Cost | When |
|-------------|---------|------|------|
| Individual (existing) | Finance app testing | €99/year | At renewal |
| Atensai Organization | Dating app commercial | €99/year | Month 3 |
| **TOTAL** | **Both apps covered** | **€198/year** | **Spread over time** |

**BONUS:** Upload finance app TODAY (no wait!)

---

### Scenario C: Membership Expired (Need to Renew)
| Account Type | Purpose | Cost | When |
|-------------|---------|------|------|
| Individual (renew) | Finance app testing | €99/year | Now |
| Atensai Organization | Dating app commercial | €99/year | Month 3 |
| **TOTAL** | **Both apps covered** | **€198/year** | **Spread over 3 months** |

---

### Scenario D: Team Member on Company Account
| Account Type | Purpose | Cost | When |
|-------------|---------|------|------|
| Team member (existing) | Work projects | €0 | Ongoing (they pay) |
| Individual (new) | Finance app testing | €99/year | Now |
| Atensai Organization | Dating app commercial | €99/year | Month 3 |
| **TOTAL** | **All apps covered** | **€198/year** | **Spread over 3 months** |

**BONUS:** Keep free team access for work projects!

---

## Action Checklist (Do This Now!)

### ☐ STEP 1: Check Status (5 minutes)
1. Go to [developer.apple.com](https://developer.apple.com)
2. Sign in with your personal Gmail-linked Apple ID
3. Look for what appears (see decision tree above)
4. Take screenshot if unclear

### ☐ STEP 2: Identify Your Scenario (1 minute)
- [ ] Scenario A: Not enrolled → Need to pay €99
- [ ] Scenario B: Active membership → USE IT NOW! 🎉
- [ ] Scenario C: Expired membership → Need to renew €99
- [ ] Scenario D: Team member → Need separate account €99

### ☐ STEP 3: Report Your Findings
Tell me which scenario matches what you see, and I'll confirm next steps.

### ☐ STEP 4: Take Appropriate Action
Based on your scenario, follow updated strategy.

---

## Important: Don't Pay Until You Verify!

**You said:** "i am sure I had been enrolled on this program before"

**This means you might:**
- ✅ Still have active membership (use it now, save €99 for 1 year!)
- ⏰ Have expired membership (renew instead of new enrollment)
- 👥 Be on team account (need separate personal account)

**5 minutes of checking = potentially save €99 or immediate app testing capability!**

---

## What to Tell Me After Checking

Copy/paste this template with your findings:

```
I checked developer.apple.com and here's what I saw:

Account Holder: [Your Name / Company Name / Not visible]
Membership Status: [Active / Expired / Not enrolled]
Role (if team member): [Admin / App Manager / Developer / Not applicable]
Renewal Date (if active): [Date / Not visible]

My screenshot: [attach if helpful]

What should I do next?
```

---

**Don't proceed with any payments until you report back! Let's make sure you're not paying twice for something you already have.**

---

**Last Updated:** March 26, 2026  
**Status:** Awaiting your status check results
