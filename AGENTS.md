<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->

# OWDT v2 — project instructions

## Purpose

Build a small personal dog training website for Mathias Porse in Risskov/Aarhus,
with a private training space for clients in an active programme.

Training is an ongoing relationship between trainer, handler and dog.
The product supports: plan → train → observe → share → feedback → adjust.

The old OWDT/Clarity repository is a reference archive. This is a clean project,
not a refactor or migration of the old application. Only port an idea, asset or
component after reviewing its relevance and dependencies.

## Training philosophy and voice

- Understand the individual dog, handler and situation before prescribing exercises.
- Support engagement, clear communication, on/off, neutrality, thoughtful reward
  placement and achievable progression.
- Make observations and adjust the plan rather than presenting one universal method.
- Give clients a safe place to share imperfect training and ask questions.
- Write public content in Danish, plainly and personally.
- Do not invent qualifications, testimonials, results, prices or availability.
- Do not turn internal training concepts into unsupported marketing claims.
- Mathias reviews the final wording about his methods and services.

## Product boundaries

The public site introduces Mathias, his approach and training services, and makes
contact easy. Suggested navigation: Forside, Tilgang, Træning, Om, Kontakt.
These can initially be sections on one page; separate routes must earn their place.

The first functional client area contains only:
- Authentication.
- Dogs and their active training programmes.
- A private timeline of focus, observations, exercises and feedback.
- Upcoming physical sessions in a simple calendar or list.

The trainer needs a minimal way to manage these records and provide feedback.
Do not build a separate administration platform.

An entry belongs to a training programme. It is not a public social post.
A client sees only their own authorised training spaces; Mathias sees those he
manages through programme membership, not because of the trainer role alone.

Deferred until the core flow works:
- Media uploads and video feedback.
- A visual exercise whiteboard and saved scenarios.
- Shared training posts from Mathias (broadcast to several programmes). Build
  only private per-programme entries until that is explicitly requested.

Out of scope:
- Social networking, followers, friends, likes and public feeds.
- General-purpose chat, AI assistants and avatars.
- Shop, payments, subscriptions and complex booking engines.
- Organisations, multi-trainer tenancy and elaborate role systems.
- Realtime infrastructure and complex notifications.
- Open self-signup.

If a request changes these boundaries, explain the tradeoff and ask whether the
product direction should change. Explicit user decisions take precedence over
this document. Do not silently expand scope.

## Agreed product decisions

These decisions are approved and must be followed in implementation.

### Accounts and login

- Only the trainer invites clients. There is no public registration.
- Login is email and password via Supabase Auth. Do not add magic links, OAuth
  or passkeys unless explicitly requested.
- An invitation must let the client choose their own password on first access.
- Include: invitation callback, logout, and password reset.
- Disable public signup in the Supabase Auth settings.

### Timeline posts

- Entry kinds: `focus`, `exercise`, `observation`, `feedback`.
- Clients may create only `observation`.
- The trainer may create all four kinds, but only on programmes where they are
  the `trainer_id`. The `trainer` profile role is not a global write grant.
- The client compose field is labelled **“Del en opdatering eller stil et
  spørgsmål”**. The app sets `kind = observation` automatically. Do not ask the
  client to pick a post type.

### Programme list

- Show `active` programmes first.
- Paused and ended programmes remain accessible to the same authorised users.

## Data model (approved for the next slices)

One Next.js app. No separate admin app. Timestamps are `timestamptz` (UTC) and
displayed in Europe/Copenhagen.

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

A programme has exactly one dog, one client and one trainer. `programmes.client_id`
must always equal `dogs.owner_id` for that `dog_id`. Enforce this in the
database (constraint and/or trigger), not only in the UI.

No contact-message table in v1. Contact stays on the public page (`mailto:` or a
later simple form).

## Access rules

Hiding UI is not access control. Use Supabase Row Level Security and repeat
authorisation in server code (layouts, pages, server actions).

Helpers:

- `is_trainer()` — current user’s `profiles.role` is `trainer`.
- `can_access_programme(id)` — `programmes.trainer_id = auth.uid()` **or**
  `programmes.client_id = auth.uid()`.

`is_trainer()` may be used to allow creating a new programme that sets
`trainer_id = auth.uid()`. It must not grant select/update/insert on other
trainers’ programmes, dogs, entries or sessions.

| Table | SELECT | INSERT | UPDATE |
|---|---|---|---|
| `profiles` | own row; a user may read profiles of people on programmes they can access | trigger on `auth.users`, default `client` | own `display_name` only |
| `dogs` | owner, or trainer on a programme with that dog | trainer, and only with `owner_id` matching the programme client they are creating | owner (name/notes) and that programme’s trainer |
| `programmes` | `can_access_programme` | trainer, with `trainer_id = auth.uid()` and `client_id = dog.owner_id` | that programme’s trainer |
| `entries` | via programme access | client: `observation` on programmes where they are `client_id`; trainer: any kind on programmes where they are `trainer_id` | own row only |
| `sessions` | via programme access | that programme’s trainer | that programme’s trainer |

No `anon` access to private tables.

### Privileged columns

Protect these against unauthorised client writes (RLS `WITH CHECK`, `REVOKE`
direct updates, and triggers as needed):

- `profiles.role` — only a privileged server process may set `trainer`.
- `dogs.owner_id` — immutable after insert, or only via a privileged path.
- `programmes.trainer_id`, `programmes.client_id`, `programmes.dog_id`.
- `entries.author_id` — always `auth.uid()` on insert; immutable.
- `entries.programme_id` — set on insert; immutable.
- `entries.kind` — set on insert; immutable. Clients cannot insert anything
  other than `observation`.

Server actions must not trust these fields from the client. Derive `author_id`
and client `kind` on the server.

## Routes

| Route | Audience | Purpose |
|---|---|---|
| `/` | public | One page: Forside, Tilgang, Træning, Om, Kontakt |
| `/login` | public | Email and password |
| `/glemt-kodeord` | public | Request password reset |
| `/saet-kodeord` | signed-in (invite or recovery session) | Choose or replace password |
| `/auth/confirm` | Auth email links | `token_hash` + `type` (invite, recovery) |
| `/auth/callback` | Auth redirects | PKCE `code` exchange |
| `/auth/log-ud` | signed-in | Logout |
| `/forloeb` | authorised users | Programme list (active first) |
| `/forloeb/[id]` | programme members | Timeline and upcoming sessions |
| `/forloeb/nyt` | trainer creating a programme they will own | Create dog + programme + invite |

## Design direction

Carry forward the agreed OWDT design direction:

- Black and dark zinc surfaces, subdued borders and restrained blue/cyan accents.
- Generous spacing, clear hierarchy, large headings and small uppercase labels.
- Rounded cards where they improve grouping.
- A calm, serious working-dog character with a personal voice.

Avoid decorative glow, parallax, excessive animation and generic SaaS dashboards.
Use readable contrast, visible focus states, labelled controls and sensible mobile
layouts. Light typography must remain legible. Motion should be minimal and honour
reduced-motion preferences.

Treat this direction as a starting point, not a claim that the old UI has been
validated here. Review old assets and components before importing them.

## Technical principles

Preferred stack: Next.js, TypeScript, Tailwind CSS, Supabase and Vercel.
Use one application, with no separate backend or microservices.

- Prefer current official Next.js App Router and `@supabase/ssr` patterns.
- On Next.js 16+, session refresh belongs in `proxy.ts` (`export async function
  proxy`). Use `middleware.ts` only if the Next.js version still requires it.
- Create cookie-based clients with `@supabase/ssr`. Protect pages with
  `supabase.auth.getClaims()`, not `getSession()`.
- Use `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`.
  Keep the secret/service-role key on the server only.
- Prefer standard framework patterns and a small, understandable file structure.
- Add dependencies and abstractions only for a demonstrated need.
- Keep credentials out of source control; document required variables in an
  example environment file.
- Keep schema changes in versioned migrations. Avoid speculative tables.
- Any future uploads must use private storage and authorised access.

## Working agreement

The repository is the shared source of truth for Mathias, Cursor and ChatGPT.
Do not assume another agent can see local or uncommitted changes.

Current stage: slice 2A complete (schema, migrations and RLS). Do not
implement programme UI, invitation-from-app, timeline or calendar until
the next requested slice.

Build one small, usable slice at a time. Run checks appropriate to the change
and report what was actually verified. Never present a stub or mock as a working
integration.

Keep changes focused. Review existing code before editing it, avoid overwriting
unrelated work. Update these instructions when Mathias explicitly changes the
product direction.
