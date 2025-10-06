import "./globals.css";
import type { Metadata } from "next";
import { Playfair_Display, Dancing_Script } from "next/font/google";

const playfair = Playfair_Display({
  subsets: ["latin"],
  variable: "--font-serif",
  display: "swap",
});

const dancingScript = Dancing_Script({
  subsets: ["latin"],
  variable: "--font-handwriting",
  display: "swap",
});

export const metadata: Metadata = {
  title: "For My Sweet Little Bunny",
  description: "A special place just for you",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${playfair.variable} ${dancingScript.variable}`}>
      <body className="min-h-screen bg-gradient-to-b from-ghibli-cloud to-ghibli-sky">
        {children}
      </body>
    </html>
  );
} 