"use client";

import { useActionState } from "react";

import { emptyState, requestPasswordReset } from "@/app/login/actions";
import { AuthCard, Field, FormStatus, SubmitButton } from "@/app/login/ui";

export function ResetRequestForm() {
  const [state, formAction] = useActionState(requestPasswordReset, emptyState);

  return (
    <AuthCard
      title="Nyt kodeord"
      description="Skriv din e-mail. Vi sender et link, så du selv kan vælge et nyt kodeord."
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
        <FormStatus error={state.error} message={state.message} />
        <SubmitButton>Send link</SubmitButton>
      </form>
    </AuthCard>
  );
}
