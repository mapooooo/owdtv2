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

App-skelet og authentication er påbegyndt. Der er endnu ingen database, forløb
eller deployment.

Læs [AGENTS.md](./AGENTS.md) før arbejde i projektet.

## Lokal kørsel

1. Kopiér `.env.example` til `.env.local` og indsæt Supabase-nøgler.
2. I Supabase Auth: slå e-mail/kodeord til, og slå offentlig signup fra.
3. Tilføj redirect-URL'er: `/auth/callback`, `/auth/confirm` og `/saet-kodeord`
   under Site URL `http://localhost:3000` (senere produktionens domæne).
4. Opdatér invite- og recovery-skabeloner, så de peger på
   `/auth/confirm?token_hash={{ .TokenHash }}&type=invite|recovery&next=/saet-kodeord`.
5. `npm install` og `npm run dev`.

Invitationer sendes først i næste skive (træner opretter forløb). Klienten
vælger selv kodeord via `/saet-kodeord`.

Cursor kan bruges lokalt til implementering, mens commits og pushes gør arbejdet
tilgængeligt for fælles review gennem GitHub.
