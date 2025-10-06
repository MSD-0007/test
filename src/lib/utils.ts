import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Utility to generate random messages
export const getRandomMessage = (messages: string[]) => {
  const randomIndex = Math.floor(Math.random() * messages.length);
  return messages[randomIndex];
}; 