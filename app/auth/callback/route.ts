import { type NextRequest, NextResponse } from "next/server";

import { safeInternalPath } from "@/lib/auth/paths";
import { isSupabaseConfigured } from "@/lib/env";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const code = searchParams.get("code");
  const next = safeInternalPath(searchParams.get("next"), "/saet-kodeord");

  const redirectTo = request.nextUrl.clone();
  redirectTo.search = "";

  if (!isSupabaseConfigured()) {
    redirectTo.pathname = "/auth/fejl";
    return NextResponse.redirect(redirectTo);
  }

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error) {
      redirectTo.pathname = next;
      return NextResponse.redirect(redirectTo);
    }
  }

  redirectTo.pathname = "/auth/fejl";
  return NextResponse.redirect(redirectTo);
}
