'use client';

import { useEffect } from "react";
import { AuthProvider } from "@/components/auth/AuthProvider";
import AuthenticatedApp from "@/components/AuthenticatedApp";
import MusicToggle from "@/components/shared/MusicToggle";
import { SplashScreen as CapSplashScreen } from '@capacitor/splash-screen';

export default function Home() {
  useEffect(() => {
    // Hide Capacitor splash screen when app loads
    CapSplashScreen.hide();
  }, []);

  return (
    <AuthProvider>
      <main className="relative min-h-screen w-full overflow-hidden">
        <AuthenticatedApp />
        <MusicToggle />
      </main>
    </AuthProvider>
  );
} 