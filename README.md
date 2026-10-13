# OWDT v2

Et enkelt site for Mathias Porses hundetræning i Risskov og Aarhus, med et privat
træningsrum til hundeejere i aktive forløb.

Træningen fortsætter mellem de fysiske sessioner:
**Plan → Træn → Del observationer → Få feedback → Justér.**

## Første version

- Offentlig side med tilgang, træningstilbud, om Mathias og kontakt.
- Login og et privat forløb omkring hund og fører.
- Timeline med fokus, øvelser, observationer og feedback.
- Enkel oversigt over kommende træninger.

Video-feedback og et visuelt øvelseslærred kommer senere, hvis fundamentet fungerer.
Projektet skal ikke udvikle sig til et socialt netværk eller en stor community-platform.

## Retning

Roligt, mørkt og enkelt design med tydelig typografi og diskrete accenter.
Stack: Next.js, TypeScript, Tailwind CSS, Supabase og Vercel.

Det tidligere OWDT/Clarity er referencearkiv. Dette repo starter rent og overtager
kun udvalgte idéer, assets eller komponenter efter konkret vurdering.

## Status

- Skive 1: app-skelet og authentication (login, invitation-callback, kodeord, log ud).
- Skive 2A: datamodel, migration og RLS for `profiles`, `dogs`, `programmes`,
  `entries` og `sessions`. Ingen forløbs-UI, invitation fra appen, timeline eller
  kalender endnu.

Læs [AGENTS.md](./AGENTS.md) før arbejde i projektet.

## Lokal kørsel (app)

1. Kopiér `.env.example` til `.env.local` og indsæt Supabase-nøgler.
2. I Supabase Auth: slå e-mail/kodeord til, og slå offentlig signup fra.
3. Tilføj redirect-URL'er: `/auth/callback`, `/auth/confirm` og `/saet-kodeord`
   under Site URL `http://localhost:3000` (senere produktionens domæne).
4. Opdatér Auth-mailskabelonerne (to separate links):
   - Invite:
     `{{ .SiteURL }}/auth/confirm?token_hash={{ .TokenHash }}&type=invite&next=/saet-kodeord`
   - Reset password:
     `{{ .SiteURL }}/auth/confirm?token_hash={{ .TokenHash }}&type=recovery&next=/saet-kodeord`
5. `npm install` og `npm run dev`.

Invitationer sendes først i en senere skive (træner opretter forløb). Klienten
vælger selv kodeord via `/saet-kodeord`.

## Database (skive 2A)

Migrationen ligger i `supabase/migrations/`. Den opretter tabeller, triggers og RLS.
Nye Auth-brugere får automatisk `profiles.role = client`. Eksisterende Auth-brugere
backfilles i samme migration.

### Lokalt (anbefalet til tests)

Kræver Docker Desktop.

```bash
supabase start
supabase test db
```

`supabase test db` kører `supabase/tests/rls.test.sql` (pgTAP) som træner + klient A +
klient B med almindelige `authenticated`/`anon`-rettigheder. Service role bruges ikke
som bevis på adgang.

### Sæt trainer-rollen (privilegeret engangshandling)

Klienter kan ikke ændre `profiles.role`. Gør det i SQL som database-ejer / service
role, fx Supabase Dashboard → SQL, efter du har bekræftet målprojektet:

1. Åbn `supabase/scripts/promote_trainer.sql`.
2. Erstat `REPLACE_WITH_TRAINER_EMAIL` med din Auth-e-mail.
3. Kør scriptet **én gang**.

### Hosted projekt

Migrationer er **ikke** kørt mod det hosted Supabase-projekt. Når du er klar:
sig hvilket projekt, og kør derefter `supabase link` + `supabase db push` (eller
indsæt SQL fra migrationen i dashboardet). Appens `.env.local` peger stadig på
hosted Auth, indtil du bevidst skifter.

Cursor kan bruges lokalt til implementering, mens commits og pushes gør arbejdet
tilgængeligt for fælles review gennem GitHub.
