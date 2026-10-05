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
A client sees only their own authorised training spaces; Mathias sees those he manages.

Deferred until the core flow works:
- Media uploads and video feedback.
- A visual exercise whiteboard and saved scenarios.

Out of scope:
- Social networking, followers, friends, likes and public feeds.
- General-purpose chat, AI assistants and avatars.
- Shop, payments, subscriptions and complex booking engines.
- Organisations, multi-trainer tenancy and elaborate role systems.
- Realtime infrastructure and complex notifications.

If a request changes these boundaries, explain the tradeoff and ask whether the
product direction should change. Explicit user decisions take precedence over
this document. Do not silently expand scope.

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

- Prefer standard framework patterns and a small, understandable file structure.
- Add dependencies and abstractions only for a demonstrated need.
- Keep credentials out of source control; document required variables in an
  example environment file when the application is initialised.
- Keep privileged Supabase credentials on the server.
- Enforce access to private records with Supabase Row Level Security and validate
  authorisation on the server. Hiding UI is not an access control.
- Any future uploads must use private storage and authorised access.
- Keep schema changes in versioned migrations. Avoid speculative tables.
- Treat profiles, dogs, programmes, sessions and entries as candidate concepts,
  not an approved schema. Propose the smallest model before implementing it.
- Store session timestamps consistently and display them in Europe/Copenhagen.

## Working agreement

The repository is the shared source of truth for Mathias, Cursor and ChatGPT.
Do not assume another agent can see local or uncommitted changes.

Current stage: documentation only. Do not initialise the app, provision services
or implement functionality until Mathias requests the next stage.

At the next stage:
1. Read this file and inspect the repository.
2. Propose the minimal structure, routes, data model and access rules.
3. Resolve material product questions before substantial implementation.
4. Build one small, usable slice at a time.
5. Run checks appropriate to the change and report what was actually verified.

Keep changes focused. Review existing code before editing it, avoid overwriting
unrelated work, and never present a stub or mock as a working integration.
Update these instructions when Mathias explicitly changes the product direction.
