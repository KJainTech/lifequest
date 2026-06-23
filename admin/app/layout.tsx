import type { Metadata } from "next";
import { AdminGuardNote } from "@/components/AdminGuardNote";
import { Sidebar } from "@/components/Sidebar";
import "./globals.css";

export const metadata: Metadata = {
  title: "LifeQuest Admin",
  description: "Internal admin console for LifeQuest Phase 11",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="min-h-screen font-sans">
        <div className="flex min-h-screen">
          <Sidebar />
          <main className="flex-1 overflow-auto p-8">
            <AdminGuardNote />
            {children}
          </main>
        </div>
      </body>
    </html>
  );
}
