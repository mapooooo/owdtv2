import Link from "next/link";

import { SetPasswordForm } from "@/app/saet-kodeord/set-password-form";
import { AuthCard } from "@/app/login/ui";
import { isSupabaseConfigured } from "@/lib/env";
import { createClient } from "@/lib/supabase/server";

export default async function SetPasswordPage() {
  if (!isSupabaseConfigured()) {
    return (
      <AuthCard
        title="Vælg kodeord"
        description="Supabase er ikke sat op endnu. Tilføj nøglerne i .env.local."
      >
        <p className="text-sm text-zinc-400">Ingen session at opdatere.</p>
      </AuthCard>
    );
  }

  const supabase = await createClient();
  const { data } = await supabase.auth.getClaims();

  if (!data?.claims) {
    return (
      <AuthCard
        title="Linket virker ikke"
        description="Invitationen eller nulstillingslinket er ugyldigt eller udløbet."
      >
        <p className="text-sm text-zinc-400">
          <Link
            className="text-zinc-200 underline-offset-4 hover:underline"
            href="/glemt-kodeord"
          >
            Anmod om et nyt link
          </Link>
        </p>
      </AuthCard>
    );
  }

  return <SetPasswordForm />;
}
