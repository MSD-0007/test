'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from '@/lib/firebase';
import { Button } from '@/components/shared/ui/button';
import { Input } from '@/components/shared/ui/input';
import { useToast } from '@/hooks/use-toast';
import { Heart, Mail, Lock, Eye, EyeOff } from 'lucide-react';

interface LoginFormProps {
  onLoginSuccess: () => void;
}

export default function LoginForm({ onLoginSuccess }: LoginFormProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isVisible, setIsVisible] = useState(true);
  const { toast } = useToast();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      console.log('🔐 Attempting login with:', email);
      
      await signInWithEmailAndPassword(auth, email, password);
      
      console.log('✅ Login successful!');
      
      toast({
        title: "Welcome Back! 💕",
        description: "Successfully logged in to your secret love space",
      });

      // Smooth transition out
      setIsVisible(false);
      setTimeout(() => {
        onLoginSuccess();
      }, 500);

    } catch (error: any) {
      console.error('❌ Login failed:', error);
      
      let errorMessage = 'Please check your credentials and try again.';
      
      if (error.code === 'auth/user-not-found') {
        errorMessage = 'This email is not registered. Please check the email address.';
      } else if (error.code === 'auth/wrong-password') {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (error.code === 'auth/invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      } else if (error.code === 'auth/too-many-requests') {
        errorMessage = 'Too many failed attempts. Please wait a moment and try again.';
      }

      toast({
        title: "Login Failed",
        description: errorMessage,
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleQuickFill = () => {
    setEmail('us@love.com');
    setPassword('AnF');
  };

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          initial={{ opacity: 0, scale: 0.9, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.9, y: -20 }}
          transition={{ duration: 0.5, ease: "easeOut" }}
          className="w-full max-w-md mx-auto p-8"
        >
          <div className="text-center mb-8">
            <motion.div
              animate={{ 
                scale: [1, 1.1, 1],
                rotate: [0, 5, -5, 0]
              }}
              transition={{ 
                duration: 2,
                repeat: Infinity,
                ease: "easeInOut"
              }}
              className="inline-block mb-4"
            >
              <Heart className="w-16 h-16 text-pink-400 mx-auto" fill="currentColor" />
            </motion.div>
            
            <h1 className="text-4xl font-serif font-bold text-white mb-2">
              Welcome Back
            </h1>
            <p className="text-white/80 text-lg mb-6">
              Enter your secret credentials to access your love space
            </p>
            
            {/* Predefined Credentials Display */}
            <motion.div 
              className="bg-white/10 backdrop-blur-sm rounded-xl p-4 mb-2 border border-white/20"
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.6 }}
            >
              <p className="text-white/90 text-sm font-medium mb-2">Your Login Credentials:</p>
              <div className="space-y-1">
                <p className="text-white text-sm flex items-center justify-center gap-2">
                  <Mail className="w-4 h-4" /> us@love.com
                </p>
                <p className="text-white text-sm flex items-center justify-center gap-2">
                  <Lock className="w-4 h-4" /> AnF
                </p>
              </div>
            </motion.div>
          </div>

          <form onSubmit={handleLogin} className="space-y-6">
            <div className="space-y-4">
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-white/60" />
                <Input
                  type="email"
                  placeholder="Email address"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="pl-12 bg-white/10 border-white/20 text-white placeholder:text-white/60 backdrop-blur-xl"
                  required
                />
              </div>

              <div className="relative">
                <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-white/60" />
                <Input
                  type={showPassword ? "text" : "password"}
                  placeholder="Password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="pl-12 pr-12 bg-white/10 border-white/20 text-white placeholder:text-white/60 backdrop-blur-xl"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-white/60 hover:text-white transition-colors"
                >
                  {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
            </div>

            <div className="space-y-4">
              <Button
                type="submit"
                disabled={isLoading}
                className="w-full bg-gradient-to-r from-pink-500 to-rose-500 hover:from-pink-600 hover:to-rose-600 text-white font-semibold py-3 px-6 rounded-xl shadow-xl backdrop-blur-xl border border-white/20 transition-all duration-300"
              >
                {isLoading ? (
                  <div className="flex items-center justify-center space-x-2">
                    <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    <span>Signing In...</span>
                  </div>
                ) : (
                  <div className="flex items-center justify-center space-x-2">
                    <Heart className="w-5 h-5" fill="currentColor" />
                    <span>Enter Love Space</span>
                  </div>
                )}
              </Button>

              <button
                type="button"
                onClick={handleQuickFill}
                className="w-full text-white/60 hover:text-white text-sm py-2 transition-colors"
              >
                Quick Fill (Development)
              </button>
            </div>
          </form>

          <div className="mt-8 text-center">
            <p className="text-white/40 text-sm">
              🔒 Your love is secured with authentication
            </p>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}