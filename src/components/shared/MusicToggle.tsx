"use client";

import React, { useState, useEffect } from "react";
import { Button } from "@/components/shared/ui/button";
import { Music, Music2 } from "lucide-react";

export default function MusicToggle() {
  const [isPlaying, setIsPlaying] = useState(false);
  const [audio, setAudio] = useState<HTMLAudioElement | null>(null);
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
    
    // Only try to load audio if file exists
    try {
      const audioElement = new Audio("/audio/lofi.mp3");
      audioElement.loop = true;
      audioElement.volume = 0.4;
      
      // Handle audio loading errors gracefully
      audioElement.addEventListener('error', () => {
        console.log('Audio file not found - music feature disabled');
        setAudio(null);
      });
      
      setAudio(audioElement);
    } catch (error) {
      console.log('Audio not available');
      setAudio(null);
    }

    return () => {
      if (audio) {
        audio.pause();
        audio.src = "";
      }
    };
  }, []);

  const toggleMusic = () => {
    if (!audio) return;

    if (isPlaying) {
      audio.pause();
    } else {
      audio.play().catch(() => {
        console.log('Audio playback failed');
      });
    }
    
    setIsPlaying(!isPlaying);
  };

  // Don't render if audio not available or not mounted
  if (!isMounted || !audio) return null;

  return (
    <Button
      variant="glassmorphic"
      size="icon"
      onClick={toggleMusic}
      className="rounded-full h-10 w-10"
      aria-label={isPlaying ? "Pause music" : "Play music"}
    >
      {isPlaying ? (
        <Music2 className="h-5 w-5" />
      ) : (
        <Music className="h-5 w-5" />
      )}
    </Button>
  );
} 