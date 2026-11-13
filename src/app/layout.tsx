import type { Metadata, Viewport } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Miodakali — Petualangan Tani Desa",
  description:
    "Game tani santai Desa Miodakali: garap ladang, pelihara Ayumi & Sapiyu, memancing di kolam, memasak, dan jelajahi hari demi hari di desa. Dapat dimainkan langsung di peramban.",
  keywords: ["Miodakali", "game tani", "game santai", "game desa", "HTML5"],
  icons: {
    icon: "/miodakali.svg",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: "#3a4d2a",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="id" suppressHydrationWarning>
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased bg-[#2c3d20] text-foreground`}
      >
        {children}
      </body>
    </html>
  );
}
