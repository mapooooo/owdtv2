"use client";

import { useActionState } from "react";

import { updatePassword } from "@/app/login/actions";
import { emptyState } from "@/app/login/form-state";
import { AuthCard, Field, FormStatus, SubmitButton } from "@/app/login/ui";

export function SetPasswordForm() {
  const [state, formAction] = useActionState(updatePassword, emptyState);

  return (
    <AuthCard
      title="Vælg kodeord"
      description="Brug linket fra invitationen eller nulstillingsmailen, og vælg det kodeord du vil logge ind med."
    >
      <form action={formAction} className="space-y-5">
        <Field
          id="password"
          name="password"
          type="password"
          label="Nyt kodeord"
          autoComplete="new-password"
          required
        />
        <Field
          id="confirm"
          name="confirm"
          type="password"
          label="Gentag kodeord"
          autoComplete="new-password"
          required
        />
        <FormStatus error={state.error} message={state.message} />
        <SubmitButton>Gem kodeord</SubmitButton>
      </form>
    </AuthCard>
  );
}
