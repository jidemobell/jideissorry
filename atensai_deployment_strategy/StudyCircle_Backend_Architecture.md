# StudyCircle — Backend Architecture Decision
**Atensai Deployment Strategy**
*Last updated: April 2026*

---

## The Core Question

> Supabase direct vs. custom backend (FastAPI/Node) — which is right for StudyCircle?

The tl;dr: **Supabase direct is the right call for StudyCircle, specifically.** Here's why, and what the caveats are.

---

## Why the Political Party App Comparison Doesn't Apply

The discussion referenced was about a closed membership system with:
- Pre-seeded members only (no self-registration)
- Custom `member_id + PIN` auth — not supported by Supabase Auth natively
- Division-scoped admin rules written as auditable Python
- Sensitive political member data (any RLS misconfiguration = catastrophic)
- Multi-step transactional logic (closing an event auto-updates metrics, votes award points, etc.)

**StudyCircle has none of these properties.**

| Property | Political Party App | StudyCircle |
|---|---|---|
| Auth model | Custom member_id + PIN | Google, Apple, email, anonymous — all native to Supabase Auth |
| User base | Closed, pre-seeded | Open public registration, growth-dependent |
| Data sensitivity | Political member records, positions, contacts | Anonymous prayers, Bible study group locations |
| Business logic complexity | Multi-table transactions, event-closing cascades, point systems | CRUD + joins, denormalised counts |
| RLS risk surface | High — one wrong policy exposes member political data | Low — anonymous by design, posts are public by intent |
| Scale starting point | Known ceiling (~500–1000 members) | Unknown, adoption-dependent, could spike |

Supabase was the wrong answer for that app. It is the right answer for this one.

---

## Why Supabase Direct Makes Sense for StudyCircle

### 1. Auth is a native fit
Supabase Auth was built for exactly what StudyCircle uses:
- Google OAuth → one line in Flutter
- Apple Sign In → one line in Flutter
- Email/password → built-in
- Anonymous auth → built-in

There is no workaround needed. No custom JWT minting. No auth service to build and maintain.

### 2. Business logic is genuinely simple
StudyCircle's backend operations are:
- Create/read/update groups
- Create prayer posts, track ownership, bookmark them
- Track join requests
- Fetch posts for a user's radius

These are all single-table reads or simple joins. No event-triggered cascades, no point calculations, no polling percentages. Supabase handles this with zero custom code.

### 3. Adoption-dependent apps CANNOT afford infra overhead at zero traffic
If you launch a FastAPI backend on even the cheapest Hetzner VPS (€4.51/month), you are:
- Paying for uptime during zero-traffic months
- Managing SSL certs, Nginx config, deployment pipelines, API versioning
- On-call for your own infrastructure
- Writing and maintaining the entire API layer Flutter would talk to

Supabase Free tier:
- 50,000 monthly active users
- 500MB database
- 5GB bandwidth
- Unlimited API calls
- Zero infra to manage

For a consumer app trying to gain its first 1,000 users, this is not a tradeoff — it is obviously the right starting position.

### 4. Real-time is built in
The prayer wall would benefit from live updates (someone posts while you're reading). That's `supabase.from('prayer_posts').stream(...)` — one call in Flutter. On a custom backend this is a WebSocket server, a pub/sub layer, reconnection logic, and more.

### 5. The RLS surface is actually low risk here
Concerns about RLS for the political party app were valid because the data is sensitive and asymmetric (members should not see each other's data in most contexts). StudyCircle's data model is:
- Prayer posts: **anonymous and intentionally public** — everyone sees all open posts, RLS is a formality
- Groups: **public by design** — all active groups are discoverable
- Bookmarks and ownership: **user-scoped, simple** — `auth.uid() = user_id` covers both

There are 5–6 RLS policies total. They are simple. They are auditable. They are already written.

---

## What Supabase Costs Over Time

| Stage | Users | Supabase Plan | Monthly Cost |
|---|---|---|---|
| Pre-launch / MVP | 0–1,000 | Free | £0 |
| Early traction | 1,000–10,000 MAU | Free (well within limits) | £0 |
| Growth | 10,000–50,000 MAU | Free (at limit) | £0 |
| Product-market fit | 50,000+ MAU | Pro | $25/month |
| Scale | 200,000+ MAU | Pro + compute add-ons | $50–100/month |

Compare: A custom FastAPI backend with equivalent reliability (managed Postgres, load balancing, backups, monitoring) would cost $50–150/month **from day one**, plus developer time.

Supabase Pro at $25/month is a viable price for a product generating revenue. If you haven't found revenue by the time you hit 50,000 MAU, the architecture choice is not your biggest problem.

---

## The Exit Strategy

This is the honest risk to document. If StudyCircle ever needs to move away from Supabase:

**What's portable:**
- All data. Supabase is managed PostgreSQL. `pg_dump` and restore to any Postgres host. Standard SQL schema, no proprietary extensions in use.
- All Flutter client code. The `supabase_flutter` SDK calls would be replaced with HTTP calls to a new API — it's a mechanical change, not a rewrite.

**What needs to be rebuilt:**
- Auth. Supabase Auth tokens are Supabase-issued JWTs. Moving off means new auth (Firebase Auth, Auth0, or custom) and a token migration. This is real work — 1–3 weeks.
- Storage (if added later). Any user-uploaded images stored in Supabase Storage would need migrating. Currently not in use.
- Realtime subscriptions (if added). Flutter `stream()` calls would need to be replaced with WebSockets or polling.

**What does NOT need to be rebuilt:**
- The API logic itself. Because StudyCircle has no backend — the Flutter app talks to Supabase directly. If you ever add an API layer, you write it fresh with your own PostgreSQL underneath.

**Cost of exit at various stages:**

| Stage | Exit cost |
|---|---|
| Pre-PMF (<10,000 users) | Low. Auth migration is straightforward when user count is small. |
| Post-PMF (10,000–100,000 users) | Medium. Auth migration needs care. Data migration is a script. |
| At scale (100,000+ users) | Higher, but by this point you have the revenue and team to do it properly. |

The key insight: **you are not building a prison.** Supabase's data is in standard PostgreSQL. The business logic is in Flutter. The exit is feasible at any stage.

---

## When to Consider Adding a Backend

StudyCircle should add a FastAPI or Node backend when:

1. **Payment processing.** Stripe webhooks, subscription management — should never be in the client
2. **Push notifications at scale.** FCM delivery logic with user segmentation
3. **Moderation tools.** Automated prayer post flagging, content review queues, admin actions
4. **Third-party integrations.** ChurchSuite, Planning Center, church directory APIs
5. **Complex recommendation logic.** ML-based group suggestions by location + denomination + size
6. **Reporting / analytics.** Admin dashboards, engagement reports — should not run in the Flutter app

None of these exist yet. When they do, the right move is to **add a thin API layer** in front of the existing Supabase database — not to replace Supabase.

---

## Architecture as of April 2026

```
Flutter App
    │
    ├── Supabase Auth (Google, Apple, email, anonymous)
    │
    ├── Supabase Database (PostgreSQL)
    │       bible_groups
    │       group_members
    │       prayer_posts
    │       prayer_post_ownership
    │       prayer_bookmarks
    │
    └── (No backend — Flutter → Supabase direct)
```

**Future architecture (when needed):**

```
Flutter App
    │
    ├── Supabase Auth (unchanged)
    │
    ├── API Layer (FastAPI / Node — thin, stateless)
    │       Payments, notifications, moderation, integrations
    │       Talks to Supabase DB via service role key
    │
    └── Supabase Database (unchanged, still the source of truth)
```

The database does not move. The Flutter app speaks to both. The backend is additive, not a replacement.

---

## Recommendation

**Start on Supabase direct. Stay there until you have a specific reason to add a backend.**

The political party app needed a backend from day one because its auth model, data sensitivity, and business logic demanded it. StudyCircle does not have those constraints. Prematurely adding a backend would:
- Slow down the MVP
- Add infrastructure cost before revenue
- Add maintenance burden to a one-person or small team
- Solve problems that don't exist yet

When the app grows to the point where a backend is justified, it will be obvious from the feature requirements — and by that point, you'll have users, possibly revenue, and a clearer picture of what the backend actually needs to do.

The Supabase exit is available whenever you need it. The data is yours. PostgreSQL is PostgreSQL.

---

*This document is specific to StudyCircle. For the Féin membership system architecture, see the separate backend documentation.*
