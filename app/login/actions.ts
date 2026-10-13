"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

import { getSiteUrl, isSupabaseConfigured } from "@/lib/env";
import { createClient } from "@/lib/supabase/server";
import type { AuthFormState } from "@/app/login/form-state";

export async function login(
  _prev: AuthFormState,
  formData: FormData,
): Promise<AuthFormState> {
  if (!isSupabaseConfigured()) {
    return {
      error: "Supabase er ikke sat op. Tilføj nøglerne i .env.local.",
      message: null,
    };
  }

  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) {
    return { error: "Skriv e-mail og kodeord.", message: null };
  }

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    return {
      error: "Kunne ikke logge ind. Tjek e-mail og kodeord.",
      message: null,
    };
  }

  revalidatePath("/", "layout");
  redirect("/forloeb");
}

export async function requestPasswordReset(
  _prev: AuthFormState,
  formData: FormData,
): Promise<AuthFormState> {
  if (!isSupabaseConfigured()) {
    return {
      error: "Supabase er ikke sat op. Tilføj nøglerne i .env.local.",
      message: null,
    };
  }

  const email = String(formData.get("email") ?? "").trim();

  if (!email) {
    return { error: "Skriv den e-mail, du logger ind med.", message: null };
  }

  const supabase = await createClient();
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${getSiteUrl()}/auth/callback?next=/saet-kodeord`,
  });

  if (error) {
    return {
      error: "Kunne ikke sende mailen. Prøv igen om et øjeblik.",
      message: null,
    };
  }

  return {
    error: null,
    message:
      "Hvis der findes en konto med den e-mail, sender vi et link til at vælge nyt kodeord. Ingen konto oprettes her.",
  };
}

export async function updatePassword(
  _prev: AuthFormState,
  formData: FormData,
): Promise<AuthFormState> {
  if (!isSupabaseConfigured()) {
    return {
      error: "Supabase er ikke sat op. Tilføj nøglerne i .env.local.",
      message: null,
    };
  }

  const password = String(formData.get("password") ?? "");
  const confirm = String(formData.get("confirm") ?? "");

  if (password.length < 8) {
    return {
      error: "Kodeordet skal være på mindst 8 tegn.",
      message: null,
    };
  }

  if (password !== confirm) {
    return { error: "Kodeordene er ikke ens.", message: null };
  }

  const supabase = await createClient();
  const { data } = await supabase.auth.getClaims();

  if (!data?.claims) {
    return {
      error: "Linket er udløbet eller ugyldigt. Anmod om et nyt.",
      message: null,
    };
  }

  const { error } = await supabase.auth.updateUser({ password });

  if (error) {
    return {
      error: "Kunne ikke gemme kodeordet. Prøv igen.",
      message: null,
    };
  }

  revalidatePath("/", "layout");
  redirect("/forloeb");
}
