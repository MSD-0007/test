"use client";

import React from "react";
import { motion } from "framer-motion";

const letters = [
  {
    id: 1,
    content: "My dearest love, I find myself thinking of your smile even in the busiest moments of my day. You bring light to my world in ways I never thought possible.",
    date: "June 12"
  },
  {
    id: 2,
    content: "Remember the night we watched the stars together? I felt like time stood still. Those quiet moments with you are what I cherish most.",
    date: "July 5"
  },
  {
    id: 3,
    content: "Every day with you feels like a gift. I'm so grateful for your kindness, your humor, and the way you understand me like no one else.",
    date: "August 23"
  }
];

export default function LettersSection() {
  return (
    <section className="py-16 px-4" id="letters">
      <motion.div 
        className="max-w-4xl mx-auto"
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        viewport={{ once: true }}
        transition={{ duration: 1 }}
      >
        <motion.h2 
          className="text-3xl md:text-4xl font-serif text-center mb-10"
          initial={{ y: 20, opacity: 0 }}
          whileInView={{ y: 0, opacity: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.2, duration: 0.5 }}
        >
          Letters to You
        </motion.h2>

        <div className="space-y-8">
          {letters.map((letter, index) => (
            <motion.div
              key={letter.id}
              className="glassmorphism p-6 rounded-lg shadow-lg"
              initial={{ y: 50, opacity: 0 }}
              whileInView={{ y: 0, opacity: 1 }}
              viewport={{ once: true }}
              transition={{ delay: 0.1 * index, duration: 0.5 }}
              whileHover={{ scale: 1.02 }}
            >
              <p className="font-handwriting text-lg mb-4">{letter.content}</p>
              <p className="text-right text-sm text-foreground/70">{letter.date}</p>
            </motion.div>
          ))}
        </div>
      </motion.div>
    </section>
  );
} 