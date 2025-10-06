"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Button } from "@/components/shared/ui/button";
import { Heart } from "lucide-react";

const surpriseMessages = [
  "I'm sending you a big virtual hug right now. Can you feel it?",
  "If I were there, I'd pull you close and whisper how much I love you.",
  "Every heartbeat of mine is a reminder of your place in my life.",
  "You are my favorite thought, my favorite person, my favorite everything.",
  "Life is so much better with you in it. Thank you for being you."
];

export default function HiddenHugs() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentMessage, setCurrentMessage] = useState("");

  const openModal = () => {
    const randomIndex = Math.floor(Math.random() * surpriseMessages.length);
    setCurrentMessage(surpriseMessages[randomIndex]);
    setIsModalOpen(true);
  };

  return (
    <section className="py-16 px-4" id="hugs">
      <motion.div 
        className="max-w-4xl mx-auto text-center"
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        viewport={{ once: true }}
        transition={{ duration: 1 }}
      >
        <motion.h2 
          className="text-3xl md:text-4xl font-serif mb-8"
          initial={{ y: 20, opacity: 0 }}
          whileInView={{ y: 0, opacity: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.2, duration: 0.5 }}
        >
          Hidden Hugs
        </motion.h2>
        
        <motion.p className="mb-8 text-center max-w-xl mx-auto">
          For when you need a little extra love. Click below for a secret message.
        </motion.p>

        <motion.div
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          <Button 
            onClick={openModal}
            variant="love"
            size="lg"
            className="rounded-full px-6 py-6 h-auto shadow-xl flex items-center gap-3"
          >
            <Heart className="h-5 w-5 animate-pulse-gentle" />
            <span className="font-handwriting text-lg">Send me a hug</span>
          </Button>
        </motion.div>
      </motion.div>

      {/* Modal */}
      <AnimatePresence>
        {isModalOpen && (
          <motion.div 
            className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setIsModalOpen(false)}
          >
            <motion.div 
              className="bg-white/90 backdrop-blur-md p-8 rounded-xl max-w-md w-full shadow-2xl relative border border-white/40"
              initial={{ scale: 0.9, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.9, y: 20 }}
              onClick={(e) => e.stopPropagation()}
            >
              <motion.div 
                className="absolute -top-4 -left-4 h-12 w-12 bg-love rounded-full flex items-center justify-center"
                initial={{ rotate: 0 }}
                animate={{ rotate: 360 }}
                transition={{ duration: 1 }}
              >
                <Heart className="h-6 w-6 text-white" fill="white" />
              </motion.div>
              <h3 className="text-2xl font-serif mb-4 text-love-dark">A Secret Hug</h3>
              <p className="font-handwriting text-xl mb-6">{currentMessage}</p>
              <div className="flex justify-end">
                <Button 
                  onClick={() => setIsModalOpen(false)}
                  variant="ghibli"
                  className="font-handwriting"
                >
                  Close
                </Button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </section>
  );
}