import type { Metadata } from "next";

import "./globals.css";

export const metadata: Metadata = {
  title: "OWDT — hundetræning i Risskov og Aarhus",
  description:
    "Privat træningsrum og offentlig side for Mathias Porses hundetræning.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="da">
      <body className="min-h-full antialiased">{children}</body>
    </html>
  );
}
