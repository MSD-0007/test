"use client";

import React, { useState, useEffect } from "react";
import { Input } from "@/components/shared/ui/input";
import { Button } from "@/components/shared/ui/button";
import { motion } from "framer-motion";
import { Heart, Lock } from "lucide-react";

interface PasswordProtectionProps {
  correctPassword?: string;
  userId: string;
  onAuthenticated?: () => void;
}

export default function PasswordProtection({ correctPassword = "AnF", userId, onAuthenticated }: PasswordProtectionProps) {
  const [password, setPassword] = useState("");
  const [showError, setShowError] = useState(false);
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  }, []);

  const handlePasswordSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (password === correctPassword) {
      localStorage.setItem("secretLoveUserId", userId);
      console.log("Password verified, userId stored:", userId);
      
      if (onAuthenticated) {
        onAuthenticated();
      }
    } else {
      console.log("Incorrect password");
      setShowError(true);
      setTimeout(() => setShowError(false), 2000);
      setPassword("");
    }
  };

  if (!isMounted) return null;

  return (
    <div className="w-full max-w-md px-4">
      <motion.div 
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
        className="glassmorphism p-8 rounded-2xl backdrop-blur-xl bg-white/10"
      >
        <div className="text-center mb-8">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
            className="inline-block mb-4"
          >
            <div className="relative">
              <Heart className="w-16 h-16 text-pink-300 fill-pink-300" />
              <Lock className="w-6 h-6 text-white absolute bottom-0 right-0 bg-blue-500 rounded-full p-1" />
            </div>
          </motion.div>
          
          <h1 className="text-3xl md:text-4xl font-serif text-white mb-2">
            Enter Password
          </h1>
          
          <p className="text-white/70 text-sm">
            {userId === "ndg" ? " Him" : " Her"}
          </p>
        </div>
        
        <motion.form 
          onSubmit={handlePasswordSubmit}
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.3, duration: 0.5 }}
          className="space-y-6"
        >
          <div className="space-y-2">
            <Input
              type="password"
              placeholder="Type the secret password..."
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className={"w-full px-4 py-6 text-lg rounded-xl bg-white/20 backdrop-blur-sm border-2 text-white placeholder-white/50 focus:outline-none focus:border-pink-400 focus:ring-2 focus:ring-pink-400/20 transition-all duration-200 " + (showError ? "border-red-400 animate-shake" : "border-white/30")}
              autoFocus
            />
            
            {showError && (
              <motion.p
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-red-300 text-sm text-center"
              >
                 Incorrect password, try again
              </motion.p>
            )}
          </div>
          
          <Button
            type="submit"
            disabled={!password.trim()}
            className="w-full py-6 text-lg font-semibold rounded-xl bg-gradient-to-r from-pink-500 to-rose-500 hover:from-pink-600 hover:to-rose-600 disabled:opacity-50 disabled:cursor-not-allowed text-white shadow-lg transition-all duration-200 hover:scale-105 active:scale-95"
          >
            Continue 
          </Button>
        </motion.form>
        
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="text-center text-white/50 text-xs mt-6"
        >
          The password is known only to you 
        </motion.p>
      </motion.div>
    </div>
  );
}

