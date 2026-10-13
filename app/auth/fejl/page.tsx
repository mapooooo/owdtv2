import Link from "next/link";

import { AuthCard } from "@/app/login/ui";

export default function AuthErrorPage() {
  return (
    <AuthCard
      title="Linket kunne ikke bruges"
      description="Invitationen eller nulstillingen kunne ikke bekræftes. Linket kan være brugt eller udløbet."
    >
      <p className="text-sm text-zinc-400">
        <Link
          className="text-zinc-200 underline-offset-4 hover:underline"
          href="/login"
        >
          Gå til login
        </Link>
        {" · "}
        <Link
          className="text-zinc-200 underline-offset-4 hover:underline"
          href="/glemt-kodeord"
        >
          Nyt kodeord
        </Link>
      </p>
    </AuthCard>
  );
}
