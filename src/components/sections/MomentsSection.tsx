"use client";

import React from "react";
import { motion } from "framer-motion";
import Image from "next/image";

const moments = [
  { 
    id: 1, 
    src: "/images/placeholders/moment1.jpg", 
    alt: "Our first date", 
    caption: "Where it all began" 
  },
  { 
    id: 2, 
    src: "/images/placeholders/moment2.jpg", 
    alt: "Beach sunset", 
    caption: "That perfect sunset" 
  },
  { 
    id: 3, 
    src: "/images/placeholders/moment3.jpg", 
    alt: "Coffee shop moment", 
    caption: "Morning coffee talks" 
  },
  { 
    id: 4, 
    src: "/images/placeholders/moment4.jpg", 
    alt: "Hiking adventure", 
    caption: "Adventure time" 
  },
  { 
    id: 5, 
    src: "/images/placeholders/moment5.jpg", 
    alt: "Cozy night in", 
    caption: "Movie night cuddles" 
  },
  { 
    id: 6, 
    src: "/images/placeholders/moment6.jpg", 
    alt: "Dinner date", 
    caption: "Candlelight dinner" 
  },
];

export default function MomentsSection() {
  return (
    <section className="py-16 px-4 bg-gradient-to-b from-ghibli-cloud/30 to-ghibli-sky/30" id="moments">
      <motion.div 
        className="max-w-6xl mx-auto"
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
          Us in Moments
        </motion.h2>

        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
          {moments.map((moment, index) => (
            <motion.div
              key={moment.id}
              className="glassmorphism overflow-hidden rounded-lg"
              initial={{ scale: 0.9, opacity: 0 }}
              whileInView={{ scale: 1, opacity: 1 }}
              viewport={{ once: true }}
              transition={{ delay: 0.1 * index, duration: 0.5 }}
              whileHover={{ y: -5, boxShadow: "0 10px 25px -5px rgba(0, 0, 0, 0.1)" }}
            >
              <div className="relative h-64 w-full">
                <div className="absolute inset-0 bg-ghibli-sky/20 flex items-center justify-center">
                  <p className="text-foreground/70 font-handwriting text-lg">Your photo here</p>
                </div>
                {/* Placeholder for actual images */}
                {/* <Image 
                  src={moment.src}
                  alt={moment.alt}
                  fill
                  className="object-cover transition-all hover:scale-105"
                /> */}
              </div>
              <div className="p-4">
                <p className="font-handwriting text-center">{moment.caption}</p>
              </div>
            </motion.div>
          ))}
        </div>
      </motion.div>
    </section>
  );
} 