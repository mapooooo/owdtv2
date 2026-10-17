<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->

# OWDT v2 — project instructions

## How to read this file

This document is the shared source of truth for Mathias, Cursor and other agents.

**October 2026 — product direction (for review).** The sections *Purpose*,
*Work and voice*, *Public product*, *Private owner space*, *Privacy and
content*, and *What this replaces* capture a direction Mathias has approved
in conversation. They are written in detail so a second agent can review the
idea before UI or schema changes. Do not treat livestream, uploads or chat as
approved to implement until a later slice explicitly asks for them.

**Still in force and already built:** authentication (slice 1), and the
private data model plus RLS (slice 2A). Do not throw those away. Dogs,
programmes and sessions remain the join between a real dog, an owner and
Mathias. Content will attach to dogs over time.

The old OWDT/Clarity repository is a reference archive. This is a clean
project, not a refactor of that application.

If a request changes these boundaries, explain the tradeoff and ask whether
the product direction should change. Explicit user decisions take precedence.
Do not silently expand scope.

---

## Purpose

OWDT is Mathias Porse’s site in Risskov/Aarhus.

The **public product** is the dogs and the content made with them: a live
window when something is on, otherwise a clear “not live”, then the dogs,
then clips and sessions a given dog appears in. Inspiration for *first
impression* is a rundown like [sonderthon.dk](https://sonderthon.dk/) —
time, title, one line — not a classic service homepage (Tilgang / Træning /
Om as the thing you meet). Steal the **program-as-front-door** pattern.
Do not copy Twitch sub-goals, guests-as-spectacle, giveaways or chat-runs
the show.

The **private product** (login, invitation only) is for owners whose dogs
Mathias actually works with: the dog, upcoming 1-1 sessions, a short
handover if there is something to say, and later the content that exists
for *their* dog. The owner should feel **relief**, not homework. The work
is the dog’s 1-1 time. The hoped-for effect is a more need-fulfilled dog
and, over time, better self-regulation in the situations they care about.
Do not promise results, prices or testimonials.

Vibe: **dog performance coach meets content creation**. Not a trick school.
Not a social network.

---

## Work and voice

### The work (approved)

- Mathias works **1-1 with the dog**, not as a trick instructor for the
  owner. The owner is not the pupil.
- A typical shape (example, not a sold package until Mathias says so): a
  run of sessions around a given challenge, including walking / airing the
  dog. Do not invent availability or a session count in the UI.
- There may be **very light handovers** after a session (what happened, what
  to be aware of). That is enough. The owner does not run a training diary
  between sessions unless they themselves want to send a short note later.
- Recordings and public content from a dog may exist **only if the owner
  wants that**. Default is private. Consent is not a footnote; it is how
  public content is allowed to exist. This is not the implementation focus
  yet, but it is a hard rule for later media.

### Voice (approved)

- Public copy in Danish. Apolitical.
- Little “jeg jeg jeg”. The dogs and the footage are the content.
- Avoid “øvelser”, method slogans and unsupported claims.
- Short labels, names, times. Picture, name, breed on a dog.
- Mathias reviews final wording about methods and services.
- Do not invent qualifications, testimonials, results, prices or
  availability.

### What this is not

- Not teaching the handler a curriculum at home (the old
  plan → train → observe → share → feedback loop is **demoted**).
- Not open “create your dog” as a toy for anonymous visitors. Dogs in the
  private space are created by Mathias in an invited programme. Public
  “Mød hundene” shows dogs that are allowed on the public surface, not a
  self-serve kennel signup.
- Not a general chat product. Any future owner communication stays inside
  the authorised dog/programme and must not leak into public program,
  livestream or highlights unless explicitly released.

---

## Public product (`/`)

First paint should feel closer to a live/content surface than to a brochure.

### Landing order

1. **Live window**
   - If something is live: it is visible (player or clear “se med”).
   - If nothing is live: the window is **minimised**, it is stated that
     nothing is live, and the visitor is led **straight to the dogs**.
   - Do not leave a large dead player as the hero when offline.
2. **Program** (optional block, only if there is something to put on it)
   - Vertical rundown: time + day, title, one line.
   - Public items only (announced live, public outing, published drop).
   - Private client appointments do **not** belong here.
3. **Mød hundene**
   - Photo, name, breed. That is enough on the grid.
   - Click a dog → content that dog appears in (highlight-reel logic).
   - Empty and honest if there are no public dogs yet.
4. **OWDT prose** sits *under* that, small, if needed — not as the first
   meeting. No long Tilgang/Træning/Om as the front door.

Login stays available (corner) for owners.

### Content over time

Dogs and content *are* the product. Behind the scenes, content should
attach to dogs (and thus to programmes/owners). New clips will keep being
created on dogs. The public dog page is “what this dog is in”, not a
training plan.

Until media exists, the layout may be empty. Never fake a reel or a live
stream.

---

## Private owner space (login)

Audience: invited owners only. Mathias sees the programmes he is
`trainer_id` on, not the world because of the trainer role.

### What the owner should meet

- Their dog (name; later photo).
- Upcoming 1-1 sessions (simple list, Europe/Copenhagen).
- Short handover from Mathias when there is something to say.
- Later: content created with *their* dog, including items that stayed
  private.

This is **aflastning**: Mathias takes the 1-1, the walk, the work on the
named challenge. The owner should not be asked to perform as a student.

### Observations and timeline (demoted)

Slice 2A still has `entries` with kinds `focus | exercise | observation |
feedback`. That schema may remain.

**Product change:** do not build the client composer
“Del en opdatering eller stil et spørgsmål” as the core of the private
space. A later, optional short note from the owner is fine. Do not design
the app as a homework loop.

Trainer-written light handover can use existing entry kinds (e.g. `feedback`
or `focus`) or a future dedicated field. Do not add tables for this until
a slice asks.

### Programme list

- Show `active` programmes first.
- Paused and ended remain accessible to the same authorised people.

---

## Privacy and content (rules for all later media)

Three layers. Mixing them is a product bug.

| Layer | Who sees it | Examples |
|---|---|---|
| Public | anyone | live when on; published clips; public program row; dog on “Mød hundene” if allowed |
| Owner-private | Mathias + that dog’s owner | session times, handover, unreleased footage, anything the owner has not released |
| Internal | Mathias only (this product has one trainer) | working notes, pre-release cuts |

- Default for a session and its media: **owner-private**.
- Public program and “Mød hundene” only include what is explicitly public.
- Owner chat (if ever built) never becomes a public post or live overlay
  without a distinct release step.
- Future uploads: private storage, authorised access, consent recorded
  before a clip can appear on a public dog page.

Do not implement storage, live or chat in the current stage.

---

## What this replaces (so reviewers can diff)

| Earlier (slice 1–2A docs) | Now |
|---|---|
| Public: Forside, Tilgang, Træning, Om, Kontakt as the meeting | Public: live (or minimised) → dogs → that dog’s content; prose below |
| Relationship framed as trainer + handler + dog, owner trains at home | 1-1 with the dog; owner is partner with privacy, not the pupil |
| Client timeline of observations as the core loop | Owner sees dog, times, handover, later their dog’s content |
| “Create your dog” as something for visitors to do | No. Public dogs are a content index. Private dogs are invited programmes |
| Shared training posts / broadcast as a later maybe | Public content is dog-centric highlights/live, with consent |
| Design: calm dark zinc, working-dog, not SaaS | Keep calm and readable; public surface may feel more “on air” (program, live, reels) without becoming a Twitch clone |

Auth, RLS and the tables `profiles`, `dogs`, `programmes`, `entries`,
`sessions` stay. New content tables are **not** approved until a media
slice.

---

## Accounts and login (unchanged)

- Only the trainer invites clients. No public registration.
- Login is email and password via Supabase Auth. No magic links, OAuth or
  passkeys unless explicitly requested.
- Invitation lets the client choose their own password.
- Include invitation callback, logout, password reset.
- Disable public signup in Supabase Auth settings.

---

## Data model (implemented in slice 2A)

One Next.js app. No separate admin app. Timestamps are `timestamptz` (UTC)
and displayed in Europe/Copenhagen.

Roles on `profiles`: `trainer` | `client`. One trainer in this product.

```
auth.users
    └── profiles          id = auth.users.id
                          role: trainer | client
                          display_name
            ├── dogs      owner_id → profiles.id
                          name
                          notes (optional)
            └── programmes
                  dog_id, client_id, trainer_id
                  status: active | paused | ended
                  title
                  current_focus
                        ├── entries
                        │     programme_id, author_id
                        │     kind: focus | exercise | observation | feedback
                        │     body
                        │     created_at
                        └── sessions
                              programme_id
                              starts_at
                              location (optional)
                              notes (optional)
```

A programme has exactly one dog, one client and one trainer.
`programmes.client_id` must equal `dogs.owner_id` for that `dog_id`
(enforced in the database).

No contact-message table. Public contact can wait; the front door is
content, not a form.

**Likely later (not in the database yet):** media objects with
`dog_id`, visibility (`public` | `owner` | `internal`), consent, and
optional `session_id` / `programme_id`. Do not add them until asked.

---

## Access rules (implemented in slice 2A)

Hiding UI is not access control. Use RLS and repeat authorisation in
server code.

Helpers:

- `is_trainer()` — `profiles.role` is `trainer` for `auth.uid()`.
- `can_access_programme(id)` — `trainer_id = auth.uid()` or
  `client_id = auth.uid()`.

`is_trainer()` may be used to create a programme with
`trainer_id = auth.uid()`. It must not grant access to other trainers’
rows.

| Table | SELECT | INSERT | UPDATE |
|---|---|---|---|
| `profiles` | own row; profiles of people on programmes the user can access | trigger on `auth.users`, default `client` | own `display_name` only |
| `dogs` | owner, or trainer on a programme with that dog (plus orphan-dog select for the creating trainer — see migration) | trainer, `owner_id` a client | owner (name/notes) and that programme’s trainer |
| `programmes` | `can_access_programme` | trainer, `trainer_id = auth.uid()`, `client_id = dog.owner_id` | that programme’s trainer |
| `entries` | via programme access | client: `observation` on own programmes; trainer: any kind on own programmes | own row only |
| `sessions` | via programme access | that programme’s trainer | that programme’s trainer |

No `anon` access to private tables. Public dog/content pages will need an
**explicit public subset** later (separate policies or a public view). Do
not open `dogs` to `anon` without a visibility flag.

### Privileged columns

- `profiles.role` — only a privileged server process may set `trainer`.
- `dogs.owner_id` — immutable after insert.
- `programmes.trainer_id`, `client_id`, `dog_id` — immutable.
- `entries.author_id` — `auth.uid()` on insert; immutable.
- `entries.programme_id`, `kind` — set on insert; immutable.

Promote trainer with `supabase/scripts/promote_trainer.sql` as a one-off
SQL role, not from the app.

---

## Routes

Current (built): `/`, `/login`, `/glemt-kodeord`, `/saet-kodeord`,
`/auth/confirm`, `/auth/callback`, `/auth/log-ud`, `/forloeb` (placeholder).

Intended public/private split (not all built):

| Route | Audience | Purpose |
|---|---|---|
| `/` | public | Live (or minimised) → program if any → Mød hundene |
| `/hunde/[id]` | public | Content that dog appears in (empty until media) |
| `/login` … `/auth/*` | as today | Auth |
| `/forloeb` | invited | Owner: dog(s), upcoming sessions, handover |
| `/forloeb/[id]` | members | Same for one programme |
| `/forloeb/nyt` | trainer | Create dog + programme + invite (later) |

---

## Design direction

- Dark surfaces, restrained accents, large type, small uppercase labels
  still apply.
- Public first screen: rundown + dogs, not a SaaS dashboard and not a
  five-section brochure.
- When live is off, shrink that chrome; do not dominate the page with a
  black rectangle.
- Readable contrast, visible focus, sensible mobile, honour
  `prefers-reduced-motion`.
- Do not import old OWDT chrome without reviewing it.

---

## Technical principles

Preferred stack: Next.js, TypeScript, Tailwind CSS, Supabase and Vercel.
One application.

- Current Next.js App Router and `@supabase/ssr`.
- Next.js 16+: session refresh in `proxy.ts`. Protect with `getClaims()`.
- `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`.
  Secret key server-only.
- Versioned migrations. No speculative tables.
- Future uploads: private storage and authorised access.

---

## Scope for implementers

**Do not implement until the next requested slice:** public program/dogs
UI, owner session list, invitation-from-app, media, live, chat, whiteboard.

**Out of scope unless Mathias explicitly expands the product:** social
graph, followers, likes, public comments, general-purpose chat, AI
assistants, shop, payments, complex booking, multi-trainer tenancy,
realtime infrastructure as a platform.

**Deferred on purpose:** livestream player, uploads, highlight pipeline,
consent UI, public visibility flags on dogs/media.

---

## Working agreement

The repository is the shared source of truth. Do not assume another agent
can see local or uncommitted changes.

Current stage: slice 2A complete (schema, migrations, RLS) on local and
hosted; Mathias’s profile promoted to `trainer`. Product direction above
is for **review**. Next implementation slice must be requested explicitly
(likely public landing as live/dogs, and/or private dog + sessions without
an observation composer).

Build one small, usable slice at a time. Report what was actually verified.
Never present a stub as a working live stream or a fake reel.

Update this file when Mathias explicitly changes the product direction.

---

## Notes for a reviewing agent

Please challenge at least:

1. Is “dogs + content as the front door” compatible with invitation-only
   private work, or does public “Mød hundene” leak client dogs?
2. Is a minimised live window honest enough when most days nothing is live?
3. Does demoting observations leave the owner with too little voice?
4. Should public dogs be a separate “published” set, never the same row as
   a private client dog until consent is stored?
5. Any conflict with existing RLS if `/hunde/[id]` is public before a
   visibility column exists?

Do not implement those answers into schema without Mathias confirming.
