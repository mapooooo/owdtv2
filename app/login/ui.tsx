import type { ReactNode } from "react";
import Link from "next/link";

export function AuthCard({
  title,
  description,
  children,
}: {
  title: string;
  description: string;
  children: ReactNode;
}) {
  return (
    <main className="mx-auto flex min-h-full max-w-md flex-col justify-center px-6 py-16">
      <p className="text-xs font-medium tracking-[0.2em] text-cyan-400 uppercase">
        OWDT
      </p>
      <h1 className="mt-4 text-3xl font-medium tracking-tight text-zinc-50">
        {title}
      </h1>
      <p className="mt-3 text-sm leading-6 text-zinc-400">{description}</p>
      <div className="mt-10 rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
        {children}
      </div>
      <p className="mt-8 text-sm text-zinc-500">
        <Link className="text-zinc-300 underline-offset-4 hover:underline" href="/">
          Til forsiden
        </Link>
      </p>
    </main>
  );
}

export function Field({
  id,
  label,
  type,
  name,
  autoComplete,
  required,
}: {
  id: string;
  label: string;
  type: string;
  name: string;
  autoComplete?: string;
  required?: boolean;
}) {
  return (
    <div className="space-y-2">
      <label className="block text-sm text-zinc-300" htmlFor={id}>
        {label}
      </label>
      <input
        id={id}
        name={name}
        type={type}
        autoComplete={autoComplete}
        required={required}
        className="w-full rounded-lg border border-zinc-700 bg-zinc-950 px-3 py-2 text-zinc-100 outline-none focus-visible:ring-2 focus-visible:ring-cyan-500"
      />
    </div>
  );
}

export function SubmitButton({ children }: { children: ReactNode }) {
  return (
    <button
      type="submit"
      className="w-full rounded-lg bg-cyan-700 px-4 py-2.5 text-sm font-medium text-white outline-none hover:bg-cyan-600 focus-visible:ring-2 focus-visible:ring-cyan-400"
    >
      {children}
    </button>
  );
}

export function FormStatus({
  error,
  message,
}: {
  error: string | null;
  message: string | null;
}) {
  if (error) {
    return (
      <p className="text-sm text-red-300" role="alert">
        {error}
      </p>
    );
  }

  if (message) {
    return (
      <p className="text-sm text-zinc-300" role="status">
        {message}
      </p>
    );
  }

  return null;
}
