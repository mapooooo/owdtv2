import { redirect } from "next/navigation";

import { LoginForm } from "@/app/login/login-form";
import { isSupabaseConfigured } from "@/lib/env";
import { createClient } from "@/lib/supabase/server";

export default async function LoginPage() {
  if (isSupabaseConfigured()) {
    const supabase = await createClient();
    const { data } = await supabase.auth.getClaims();

    if (data?.claims) {
      redirect("/forloeb");
    }
  }

  return <LoginForm />;
}
