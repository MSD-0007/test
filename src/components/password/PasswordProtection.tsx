"use client";

import React, { useState, useEffect } from "react";
import { Input } from "@/components/shared/ui/input";
import { Button } from "@/components/shared/ui/button";
import { motion } from "framer-motion";
import { useToast } from "@/hooks/use-toast";

interface PasswordProtectionProps {
  correctPassword: string;
  onAuthenticated?: (userId: string) => void;
}

export default function PasswordProtection({ correctPassword, onAuthenticated }: PasswordProtectionProps) {
  const [password, setPassword] = useState("");
  const [userName, setUserName] = useState("");
  const [step, setStep] = useState<'password' | 'name'>('password');
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [showError, setShowError] = useState(false);
  const [isMounted, setIsMounted] = useState(false);
  const { toast } = useToast();

  useEffect(() => {
    setIsMounted(true);
  }, []);

  const handlePasswordSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (password === correctPassword) {
      setStep('name');
    } else {
      setShowError(true);
      setTimeout(() => setShowError(false), 2000);
      setPassword("");
    }
  };

  const handleNameSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (userName.trim()) {
      setIsAuthenticated(true);
      
      // Determine user ID based on name
      const userNameLower = userName.toLowerCase();
      const userId = userNameLower.includes('ndg') || userNameLower.includes('him') || userNameLower.includes('boy') 
        ? 'ndg' 
        : 'ak';
      
      // Store in localStorage
      localStorage.setItem('secretLoveUserId', userId);
      localStorage.setItem('secretLoveUserName', userName);
      
      if (onAuthenticated) {
        onAuthenticated(userId);
      }
      
      // Show the protected content
      const protectedContent = document.getElementById("protected-content");
      if (protectedContent) {
        protectedContent.classList.remove("hidden");
      }
      
      // Hide the password screen with animation
      setTimeout(() => {
        const passwordScreen = document.getElementById("password-screen");
        if (passwordScreen) {
          passwordScreen.classList.add("opacity-0");
          setTimeout(() => {
            passwordScreen.classList.add("hidden");
          }, 500);
        }
      }, 300);

      toast({
        title: `Welcome back, ${userName}! ❤️`,
        description: "So happy to see you again!",
      });
    }
  };

  if (!isMounted) return null;

  return (
    <div 
      id="password-screen"
      className="fixed inset-0 z-50 flex items-center justify-center transition-opacity duration-500 bg-gradient-to-br from-[#5865F2] via-[#4752C4] to-[#3C45A5]"
    >
      <motion.div 
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-md glassmorphism p-8 rounded-xl"
      >
        <motion.h1 
          className="text-3xl md:text-4xl font-serif text-center mb-6 text-foreground"
          initial={{ y: -20 }}
          animate={{ y: 0 }}
          transition={{ delay: 0.2, duration: 0.5 }}
        >
          Welcome, Love
        </motion.h1>
        
        {step === 'password' ? (
          <motion.form 
            onSubmit={handlePasswordSubmit} 
            className="space-y-4"
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.4, duration: 0.5 }}
          >
            <div className="space-y-2">
              <Input
                type="password"
                placeholder="Enter the secret password..."
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className={`bg-white/70 focus:bg-white/90 ${
                  showError ? "border-red-500 animate-shake" : ""
                }`}
              />
              {showError && (
                <motion.p 
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="text-red-500 text-sm mt-1"
                >
                  That's not right, try again ❤️
                </motion.p>
              )}
            </div>
            <Button type="submit" className="w-full bg-gradient-to-r from-pink-500 to-rose-500 hover:from-pink-600 hover:to-rose-600 text-white">
              Continue
            </Button>
          </motion.form>
        ) : (
          <motion.form 
            onSubmit={handleNameSubmit} 
            className="space-y-4"
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.5 }}
          >
            <div className="space-y-2">
              <Input
                type="text"
                placeholder="Who are you? (him/her)"
                value={userName}
                onChange={(e) => setUserName(e.target.value)}
                className="bg-white/70 focus:bg-white/90"
                autoFocus
              />
            </div>
            <Button type="submit" className="w-full bg-gradient-to-r from-pink-500 to-rose-500 hover:from-pink-600 hover:to-rose-600 text-white">
              Enter Our Space ❤️
            </Button>
          </motion.form>
        )}
        
        <motion.p 
          className="text-center mt-6 text-sm text-foreground/70"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6, duration: 0.5 }}
        >
          A special place, just for you
        </motion.p>
      </motion.div>

      {/* Decorative floating elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        {[...Array(8)].map((_, i) => (
          <motion.div
            key={i}
            className="sakura"
            initial={{ 
              x: Math.random() * window.innerWidth,
              y: -20,
              rotate: Math.random() * 90
            }}
            animate={{
              y: window.innerHeight + 20,
              rotate: Math.random() * 360,
              x: Math.random() * window.innerWidth
            }}
            transition={{
              duration: 10 + Math.random() * 10,
              repeat: Infinity,
              repeatType: "loop",
              delay: Math.random() * 5
            }}
            style={{
              left: `${Math.random() * 100}%`,
            }}
          />
        ))}
      </div>
    </div>
  );
} 