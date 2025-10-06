'use client';

import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Upload, Heart, X, Edit2, Check } from 'lucide-react';
import { db } from '@/lib/firebase';
import { 
  collection, 
  addDoc, 
  onSnapshot, 
  serverTimestamp, 
  query, 
  orderBy,
  updateDoc,
  doc,
  deleteDoc 
} from 'firebase/firestore';
import { useToast } from '@/hooks/use-toast';
import Image from 'next/image';

interface Moment {
  id: string;
  imageData: string; // base64 encoded image
  caption: string;
  uploadedBy: string;
  timestamp: any;
}

interface DynamicMomentsProps {
  userId: string; // 'ndg' or 'ak'
}

export default function DynamicMoments({ userId }: DynamicMomentsProps) {
  const [moments, setMoments] = useState<Moment[]>([]);
  const [uploading, setUploading] = useState(false);
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [caption, setCaption] = useState('');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editCaption, setEditCaption] = useState('');
  const fileInputRef = useRef<HTMLInputElement>(null);
  const { toast } = useToast();

  useEffect(() => {
    // Listen to moments collection
    const momentsQuery = query(
      collection(db, 'moments'),
      orderBy('timestamp', 'desc')
    );

    const unsubscribe = onSnapshot(momentsQuery, (snapshot) => {
      const momentsData: Moment[] = [];
      snapshot.forEach((doc) => {
        momentsData.push({ id: doc.id, ...doc.data() } as Moment);
      });
      setMoments(momentsData);
    });

    return () => unsubscribe();
  }, []);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setSelectedImage(e.target.files[0]);
    }
  };

  // Helper function to convert image file to base64
  const convertImageToBase64 = (file: File): Promise<string> => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => resolve(reader.result as string);
      reader.onerror = (error) => reject(error);
    });
  };

  const uploadMoment = async () => {
    if (!selectedImage) {
      toast({
        title: "No image selected",
        description: "Please select an image first",
        variant: "destructive"
      });
      return;
    }

    // Check file size (limit to 1MB for Firestore efficiency)
    if (selectedImage.size > 1 * 1024 * 1024) {
      toast({
        title: "File too large",
        description: "Please select an image under 1MB",
        variant: "destructive"
      });
      return;
    }

    setUploading(true);
    
    try {
      // Convert image to base64
      const imageData = await convertImageToBase64(selectedImage);

      // Save to Firestore as JSON data (completely free!)
      await addDoc(collection(db, 'moments'), {
        imageData, // base64 encoded string
        caption: caption || 'A beautiful moment together 💕',
        uploadedBy: userId,
        timestamp: serverTimestamp()
      });

      toast({
        title: "Moment captured! 📸",
        description: "Your beautiful memory has been added!",
      });

      // Reset form
      setSelectedImage(null);
      setCaption('');
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    } catch (error) {
      console.error('Error uploading moment:', error);
      toast({
        title: "Upload failed",
        description: "Couldn't upload the moment. Please try again.",
        variant: "destructive"
      });
    } finally {
      setUploading(false);
    }
  };

  const updateCaption = async (momentId: string, newCaption: string) => {
    try {
      await updateDoc(doc(db, 'moments', momentId), {
        caption: newCaption
      });
      setEditingId(null);
      toast({
        title: "Caption updated! ✨",
        description: "Your caption has been updated.",
      });
    } catch (error) {
      console.error('Error updating caption:', error);
      toast({
        title: "Update failed",
        description: "Couldn't update caption. Please try again.",
        variant: "destructive"
      });
    }
  };

  const deleteMoment = async (moment: Moment) => {
    if (!confirm('Are you sure you want to delete this moment?')) return;

    try {
      // Delete from Firestore only (image data is stored as base64 in the document)
      await deleteDoc(doc(db, 'moments', moment.id));

      toast({
        title: "Moment deleted",
        description: "The moment has been removed.",
      });
    } catch (error) {
      console.error('Error deleting moment:', error);
      toast({
        title: "Delete failed",
        description: "Couldn't delete moment. Please try again.",
        variant: "destructive"
      });
    }
  };

  return (
    <section className="py-16 px-4" id="moments">
      <div className="max-w-6xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center mb-10"
        >
          <h2 className="text-4xl font-serif font-bold text-white mb-4">
            Our Moments Together
          </h2>
          <p className="text-white/80">
            Every photo tells our story of love 💕
          </p>
        </motion.div>

        {/* Upload Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.2 }}
          className="blurple-glassmorphism rounded-2xl p-6 mb-10"
        >
          <h3 className="text-xl font-semibold text-white mb-4">
            Add a New Moment 📸
          </h3>
          
          <div className="space-y-4">
            <div className="flex flex-col sm:flex-row gap-4">
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                onChange={handleFileSelect}
                className="hidden"
                id="moment-upload"
              />
              <label
                htmlFor="moment-upload"
                className="flex-1 flex items-center justify-center gap-2 px-4 py-3 bg-white/10 hover:bg-white/20 text-white rounded-lg cursor-pointer transition-colors border border-white/20"
              >
                <Upload className="w-5 h-5" />
                {selectedImage ? selectedImage.name : 'Choose Photo'}
              </label>
            </div>

            {selectedImage && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                className="space-y-4"
              >
                <input
                  type="text"
                  value={caption}
                  onChange={(e) => setCaption(e.target.value)}
                  placeholder="Add a love quote or caption... 💕"
                  className="w-full px-4 py-3 bg-white/10 text-white placeholder-white/50 rounded-lg border border-white/20 focus:outline-none focus:ring-2 focus:ring-white/30"
                />

                <button
                  onClick={uploadMoment}
                  disabled={uploading}
                  className="w-full px-6 py-3 bg-gradient-to-r from-pink-500 to-rose-500 hover:from-pink-600 hover:to-rose-600 text-white font-semibold rounded-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-lg"
                >
                  {uploading ? 'Uploading...' : 'Upload Moment 💕'}
                </button>
              </motion.div>
            )}
          </div>
        </motion.div>

        {/* Moments Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <AnimatePresence>
            {moments.map((moment, index) => (
              <motion.div
                key={moment.id}
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                transition={{ delay: index * 0.05 }}
                whileHover={{ y: -5 }}
                className="blurple-glassmorphism rounded-2xl overflow-hidden group"
              >
                <div className="relative aspect-square">
                  <Image
                    src={moment.imageData}
                    alt={moment.caption}
                    fill
                    className="object-cover"
                    unoptimized
                  />
                  
                  {/* Overlay with actions */}
                  <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
                    <div className="absolute bottom-0 left-0 right-0 p-4 flex justify-between items-end">
                      <span className="text-xs text-white/70">
                        by {moment.uploadedBy === userId ? 'You' : 'Your Love'}
                      </span>
                      {moment.uploadedBy === userId && (
                        <button
                          onClick={() => deleteMoment(moment)}
                          className="p-2 bg-red-500/80 hover:bg-red-500 text-white rounded-full transition-colors"
                        >
                          <X className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                  </div>

                  {/* Heart icon */}
                  <motion.div
                    className="absolute top-3 right-3"
                    whileHover={{ scale: 1.2 }}
                  >
                    <Heart className="w-6 h-6 text-white fill-white drop-shadow-lg" />
                  </motion.div>
                </div>

                {/* Caption */}
                <div className="p-4">
                  {editingId === moment.id ? (
                    <div className="flex gap-2">
                      <input
                        type="text"
                        value={editCaption}
                        onChange={(e) => setEditCaption(e.target.value)}
                        className="flex-1 px-3 py-2 bg-white/10 text-white text-sm rounded-lg border border-white/20 focus:outline-none focus:ring-2 focus:ring-white/30"
                        autoFocus
                      />
                      <button
                        onClick={() => updateCaption(moment.id, editCaption)}
                        className="p-2 bg-green-500 hover:bg-green-600 text-white rounded-lg transition-colors"
                      >
                        <Check className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => setEditingId(null)}
                        className="p-2 bg-gray-500 hover:bg-gray-600 text-white rounded-lg transition-colors"
                      >
                        <X className="w-4 h-4" />
                      </button>
                    </div>
                  ) : (
                    <div className="flex items-start justify-between gap-2">
                      <p className="text-white/90 text-sm font-light italic flex-1">
                        "{moment.caption}"
                      </p>
                      {moment.uploadedBy === userId && (
                        <button
                          onClick={() => {
                            setEditingId(moment.id);
                            setEditCaption(moment.caption);
                          }}
                          className="p-1 hover:bg-white/10 text-white/70 hover:text-white rounded transition-colors"
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                  )}
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
        </div>

        {moments.length === 0 && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="text-center py-20"
          >
            <p className="text-white/60 text-lg">
              No moments yet. Start adding your beautiful memories together! 💕
            </p>
          </motion.div>
        )}
      </div>
    </section>
  );
}
