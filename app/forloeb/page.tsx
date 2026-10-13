import { createClient } from "@/lib/supabase/server";

export default async function ForloebPage() {
  const supabase = await createClient();
  const { data } = await supabase.auth.getClaims();
  const email =
    typeof data?.claims.email === "string" ? data.claims.email : "din konto";

  return (
    <main className="mx-auto max-w-3xl px-6 py-16">
      <p className="text-xs font-medium tracking-[0.2em] text-cyan-400 uppercase">
        Træningsrum
      </p>
      <h1 className="mt-4 text-4xl font-medium tracking-tight text-zinc-50">
        Forløb
      </h1>
      <p className="mt-4 max-w-xl text-sm leading-6 text-zinc-400">
        Du er logget ind som {email}. Selve forløbene, timeline og sessioner
        kommer i næste skive. Aktive forløb vises først, når data er på plads.
        Pausede og afsluttede forløb bliver ved med at være tilgængelige.
      </p>
      <form action="/auth/log-ud" method="post" className="mt-10">
        <button
          type="submit"
          className="rounded-lg border border-zinc-700 px-4 py-2 text-sm text-zinc-200 outline-none hover:border-zinc-500 focus-visible:ring-2 focus-visible:ring-cyan-500"
        >
          Log ud
        </button>
      </form>
    </main>
  );
}
