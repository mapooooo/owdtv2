"use client";

import { useActionState } from "react";

import { requestPasswordReset } from "@/app/login/actions";
import { emptyState } from "@/app/login/form-state";
import { AuthCard, Field, FormStatus, SubmitButton } from "@/app/login/ui";

export function ResetRequestForm() {
  const [state, formAction] = useActionState(requestPasswordReset, emptyState);

  return (
    <AuthCard
      title="Nyt kodeord"
      description="Virker kun hvis kontoen allerede findes. Glemt kodeord opretter ikke adgang."
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
