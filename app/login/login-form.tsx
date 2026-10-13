"use client";

import { useActionState } from "react";
import Link from "next/link";

import { login } from "@/app/login/actions";
import { emptyState } from "@/app/login/form-state";
import { AuthCard, Field, FormStatus, SubmitButton } from "@/app/login/ui";

export function LoginForm() {
  const [state, formAction] = useActionState(login, emptyState);

  return (
    <AuthCard
      title="Log ind"
      description="Der er ingen åben tilmelding. Klienter får en invitation. Indtil invitationen er bygget, oprettes den første konto i Supabase."
    >
      <form action={formAction} className="space-y-5">
        <Field
          id="email"
          name="email"
          type="email"
          label="E-mail"
          autoComplete="email"
          required
        />
        <Field
          id="password"
          name="password"
          type="password"
          label="Kodeord"
          autoComplete="current-password"
          required
        />
        <FormStatus error={state.error} message={state.message} />
        <SubmitButton>Log ind</SubmitButton>
      </form>
      <p className="mt-6 text-sm text-zinc-400">
        <Link
          className="text-zinc-200 underline-offset-4 hover:underline"
          href="/glemt-kodeord"
        >
          Glemt kodeord?
        </Link>
      </p>
    </AuthCard>
  );
}
