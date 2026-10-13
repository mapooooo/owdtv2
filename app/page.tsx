import Link from "next/link";

const nav = [
  { href: "#forside", label: "Forside" },
  { href: "#tilgang", label: "Tilgang" },
  { href: "#traening", label: "Træning" },
  { href: "#om", label: "Om" },
  { href: "#kontakt", label: "Kontakt" },
];

export default function HomePage() {
  return (
    <div className="min-h-full">
      <header className="border-b border-zinc-800">
        <div className="mx-auto flex max-w-5xl items-center justify-between gap-6 px-6 py-5">
          <p className="text-xs font-medium tracking-[0.2em] text-cyan-400 uppercase">
            OWDT
          </p>
          <nav className="hidden items-center gap-5 text-sm text-zinc-400 sm:flex">
            {nav.map((item) => (
              <a
                key={item.href}
                className="outline-none hover:text-zinc-100 focus-visible:text-zinc-100 focus-visible:ring-2 focus-visible:ring-cyan-500"
                href={item.href}
              >
                {item.label}
              </a>
            ))}
          </nav>
          <Link
            href="/login"
            className="rounded-lg border border-zinc-700 px-3 py-1.5 text-sm text-zinc-200 outline-none hover:border-zinc-500 focus-visible:ring-2 focus-visible:ring-cyan-500"
          >
            Log ind
          </Link>
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-6 py-20">
        <section id="forside" className="scroll-mt-24">
          <p className="text-xs font-medium tracking-[0.2em] text-cyan-400 uppercase">
            Risskov / Aarhus
          </p>
          <h1 className="mt-5 max-w-3xl text-4xl leading-tight font-medium tracking-tight text-zinc-50 sm:text-6xl">
            Hundetræning som et forløb, ikke et enkelt trick.
          </h1>
          <p className="mt-6 max-w-2xl text-base leading-7 text-zinc-400">
            OWDT er Mathias Porses træning. Den offentlige side fortæller om
            tilgang og kontakt. Klienter i et forløb får et privat rum til at
            dele observationer og få feedback mellem de fysiske træninger.
          </p>
        </section>

        <section id="tilgang" className="mt-24 scroll-mt-24">
          <p className="text-xs font-medium tracking-[0.2em] text-zinc-500 uppercase">
            Tilgang
          </p>
          <h2 className="mt-3 text-2xl text-zinc-50">Forstå hunden og føreren først</h2>
          <p className="mt-4 max-w-2xl text-sm leading-7 text-zinc-400">
            Øvelser kommer efter observation. Teksten her bliver skrevet og
            godkendt af Mathias — der står ingen opdigtede metoder eller
            resultater på siden.
          </p>
        </section>

        <section id="traening" className="mt-24 scroll-mt-24">
          <p className="text-xs font-medium tracking-[0.2em] text-zinc-500 uppercase">
            Træning
          </p>
          <h2 className="mt-3 text-2xl text-zinc-50">Forløb mellem sessionerne</h2>
          <p className="mt-4 max-w-2xl text-sm leading-7 text-zinc-400">
            Plan, træning, observation, feedback og justering. Tilbud og rammer
            beskrives her, når formuleringen er på plads. Priser og
            tilgængelighed oplyses ikke, før de er aftalt.
          </p>
        </section>

        <section id="om" className="mt-24 scroll-mt-24">
          <p className="text-xs font-medium tracking-[0.2em] text-zinc-500 uppercase">
            Om
          </p>
          <h2 className="mt-3 text-2xl text-zinc-50">Mathias Porse</h2>
          <p className="mt-4 max-w-2xl text-sm leading-7 text-zinc-400">
            Kort, personlig præsentation kommer her. Ingen opdigtede titler
            eller testimonials.
          </p>
        </section>

        <section id="kontakt" className="mt-24 mb-12 scroll-mt-24">
          <p className="text-xs font-medium tracking-[0.2em] text-zinc-500 uppercase">
            Kontakt
          </p>
          <h2 className="mt-3 text-2xl text-zinc-50">Skriv</h2>
          <p className="mt-4 max-w-2xl text-sm leading-7 text-zinc-400">
            Kontaktoplysninger sættes på, når de er klar. Indtil da: log ind
            hvis du allerede er i et forløb.
          </p>
        </section>
      </main>
    </div>
  );
}
