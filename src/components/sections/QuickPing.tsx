'use client';

import { motion } from 'framer-motion';
import { 
  Heart, 
  AlertCircle, 
  Phone, 
  HelpCircle, 
  MessageCircle, 
  Clock,
  Sparkles,
  Moon,
  Sun
} from 'lucide-react';
import { useState } from 'react';
import { sendPing as sendSocketPing } from '@/lib/socket';
import { Haptics, ImpactStyle } from '@capacitor/haptics';
import { useToast } from '@/hooks/use-toast';

export type PingType = 
  | 'missing-you'
  | 'emergency'
  | 'hear-voice'
  | 'you-okay'
  | 'free-talk'
  | 'busy'
  | 'thinking-of-you'
  | 'sweet-dreams'
  | 'good-morning';

interface Ping {
  id: PingType;
  label: string;
  message: string;
  icon: any;
  color: string;
  gradient: string;
  vibration: 'light' | 'medium' | 'heavy';
  emoji: string;
}

const pings: Ping[] = [
  {
    id: 'missing-you',
    label: 'Missing You',
    message: '💕 Your love is thinking about you right now... Missing you so much!',
    icon: Heart,
    color: 'from-pink-400 to-rose-500',
    gradient: 'bg-gradient-to-br from-pink-400/20 to-rose-500/20',
    vibration: 'medium',
    emoji: '💕'
  },
  {
    id: 'thinking-of-you',
    label: 'Thinking of You',
    message: '✨ You just crossed my mind and made me smile... Thinking of you!',
    icon: Sparkles,
    color: 'from-purple-400 to-pink-500',
    gradient: 'bg-gradient-to-br from-purple-400/20 to-pink-500/20',
    vibration: 'light',
    emoji: '✨'
  },
  {
    id: 'hear-voice',
    label: 'Need to Hear Your Voice',
    message: '📞 I really need to hear your voice right now. Can you call me?',
    icon: Phone,
    color: 'from-blue-400 to-indigo-500',
    gradient: 'bg-gradient-to-br from-blue-400/20 to-indigo-500/20',
    vibration: 'heavy',
    emoji: '📞'
  },
  {
    id: 'free-talk',
    label: 'Free to Talk?',
    message: '💬 Hey beautiful! Are you free to talk for a bit?',
    icon: MessageCircle,
    color: 'from-green-400 to-emerald-500',
    gradient: 'bg-gradient-to-br from-green-400/20 to-emerald-500/20',
    vibration: 'light',
    emoji: '💬'
  },
  {
    id: 'you-okay',
    label: 'You Okay?',
    message: '🤗 Just checking in... Are you okay, my love?',
    icon: HelpCircle,
    color: 'from-yellow-400 to-orange-500',
    gradient: 'bg-gradient-to-br from-yellow-400/20 to-orange-500/20',
    vibration: 'medium',
    emoji: '🤗'
  },
  {
    id: 'emergency',
    label: 'Emergency',
    message: '🚨 URGENT! Please call me as soon as you can. It\'s important!',
    icon: AlertCircle,
    color: 'from-red-500 to-orange-600',
    gradient: 'bg-gradient-to-br from-red-500/20 to-orange-600/20',
    vibration: 'heavy',
    emoji: '🚨'
  },
  {
    id: 'busy',
    label: 'Busy Right Now',
    message: '⏰ I\'m a bit busy at the moment, but I\'ll message you soon! Love you!',
    icon: Clock,
    color: 'from-gray-400 to-slate-500',
    gradient: 'bg-gradient-to-br from-gray-400/20 to-slate-500/20',
    vibration: 'light',
    emoji: '⏰'
  },
  {
    id: 'good-morning',
    label: 'Good Morning',
    message: '🌅 Good morning, sunshine! Hope you have the most amazing day! ☀️',
    icon: Sun,
    color: 'from-amber-400 to-yellow-500',
    gradient: 'bg-gradient-to-br from-amber-400/20 to-yellow-500/20',
    vibration: 'light',
    emoji: '🌅'
  },
  {
    id: 'sweet-dreams',
    label: 'Sweet Dreams',
    message: '🌙 Sweet dreams, my love. Can\'t wait to see you tomorrow! 💤',
    icon: Moon,
    color: 'from-indigo-400 to-purple-600',
    gradient: 'bg-gradient-to-br from-indigo-400/20 to-purple-600/20',
    vibration: 'light',
    emoji: '🌙'
  },
];

interface QuickPingProps {
  userId: string; // 'ndg' or 'ak'
}

export default function QuickPing({ userId }: QuickPingProps) {
  const [sending, setSending] = useState<PingType | null>(null);
  const { toast } = useToast();

  const sendPing = async (ping: Ping) => {
    console.log('🚀 sendPing called for:', ping.id);
    console.log('👤 Current userId:', userId);
    console.log('📤 Sending to:', userId === 'ndg' ? 'ak' : 'ndg');
    
    setSending(ping.id);
    
    try {
      // Haptic feedback (try-catch to not block on web)
      try {
        await Haptics.impact({ style: ImpactStyle.Medium });
      } catch (e) {
        console.log('⚠️ Haptics not available (probably web browser)');
      }
      
      const recipientId = userId === 'ndg' ? 'ak' : 'ndg';
      
      console.log(`⚡ Sending ping to ${recipientId} via Socket.IO`);
      
      // Send via Socket.IO
      const sent = sendSocketPing(recipientId, userId, ping.message);
      
      if (!sent) {
        throw new Error('Socket not connected');
      }
      
      console.log('✅ Ping sent successfully via Socket.IO');

      // Success haptic
      try {
        await Haptics.notification({ type: 'success' } as any);
      } catch (e) {
        console.log('⚠️ Success haptic not available');
      }
      
      toast({
        title: "Ping Sent! 💕",
        description: `Your "${ping.label}" ping has been delivered instantly!`,
      });
    } catch (error) {
      console.error('❌ ERROR sending ping:', error);
      
      try {
        await Haptics.notification({ type: 'error' } as any);
      } catch (e) {
        console.log('⚠️ Error haptic not available');
      }
      
      toast({
        title: "Oops!",
        description: "Couldn't send ping. Check your connection.",
        variant: "destructive"
      });
    } finally {
      console.log('🏁 sendPing finished, resetting sending state');
      setSending(null);
    }
  };

  return (
    <div className="w-full max-w-4xl mx-auto p-6">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-8"
      >
        <h2 className="text-3xl font-serif font-bold text-white mb-2">
          Quick Pings
        </h2>
        <p className="text-white/80">
          Send a quick message to let them know what's on your mind
        </p>
      </motion.div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {pings.map((ping, index) => {
          const Icon = ping.icon;
          const isSending = sending === ping.id;
          
          return (
            <motion.button
              key={ping.id}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.05 }}
              whileHover={{ scale: 1.05, y: -5 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => sendPing(ping)}
              disabled={isSending}
              className={`
                relative overflow-hidden rounded-2xl p-6
                ${ping.gradient}
                backdrop-blur-xl border border-white/20
                shadow-xl hover:shadow-2xl
                transition-all duration-300
                disabled:opacity-50 disabled:cursor-not-allowed
                group
              `}
            >
              {/* Shimmer effect on hover */}
              <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent translate-x-[-200%] group-hover:translate-x-[200%] transition-transform duration-1000" />
              
              <div className="relative z-10 flex flex-col items-center space-y-3">
                <motion.div
                  animate={isSending ? { 
                    rotate: [0, -10, 10, -10, 10, 0],
                    scale: [1, 1.1, 1, 1.1, 1]
                  } : {}}
                  transition={{ duration: 0.5 }}
                  className={`
                    p-4 rounded-full bg-gradient-to-br ${ping.color}
                    shadow-lg
                  `}
                >
                  <Icon className="w-8 h-8 text-white" />
                </motion.div>
                
                <div className="text-center">
                  <h3 className="text-lg font-semibold text-white mb-1">
                    {ping.emoji} {ping.label}
                  </h3>
                  <p className="text-xs text-white/70 line-clamp-2">
                    {ping.message}
                  </p>
                </div>

                {isSending && (
                  <motion.div
                    animate={{ rotate: 360 }}
                    transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                    className="absolute inset-0 flex items-center justify-center bg-black/20 backdrop-blur-sm rounded-2xl"
                  >
                    <div className="w-8 h-8 border-4 border-white/30 border-t-white rounded-full" />
                  </motion.div>
                )}
              </div>
            </motion.button>
          );
        })}
      </div>
    </div>
  );
}
