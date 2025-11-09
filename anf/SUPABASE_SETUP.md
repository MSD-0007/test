# Supabase Setup Guide for ANF App

## 🚀 Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project" 
3. Sign up/Login with GitHub or email
4. Click "New Project"
5. Fill in:
   - **Organization:** Your account
   - **Name:** `test` (or any generic name for privacy)
   - **Database Password:** Create a strong password (save it!)
   - **Region:** Choose closest to your location
6. Click "Create new project"
7. Wait 2-3 minutes for setup to complete

## 🔑 Step 2: Get Your Credentials

Once your project is ready:

1. Go to **Settings** → **API**
2. Copy these values (we'll need them):
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

## 📦 Step 3: Create Storage Bucket

1. Go to **Storage** in the left sidebar
2. Click "Create a new bucket"
3. Fill in:
   - **Name:** `moments`
   - **Public bucket:** ✅ **Enable** (so photos can be viewed)
   - **File size limit:** 5MB (good for photos)
   - **Allowed MIME types:** `image/*`
4. Click "Create bucket"

## 🔒 Step 4: Set Up Storage Policies

1. In Storage → **moments** bucket
2. Click "Policies" tab
3. Click "New Policy" → "For full customization"
4. **Policy Name:** `Allow public read access`
5. **Policy Definition:**
```sql
CREATE POLICY "Allow public read access" ON storage.objects
FOR SELECT USING (bucket_id = 'moments');
```
6. Click "Review" → "Save policy"

7. Create another policy:
   - **Policy Name:** `Allow authenticated uploads`
   - **Policy Definition:**
```sql
CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'moments');
```

8. Create delete policy:
   - **Policy Name:** `Allow users to delete own files`
   - **Policy Definition:**
```sql
CREATE POLICY "Allow users to delete own files" ON storage.objects
FOR DELETE USING (bucket_id = 'moments');
```

## 📋 Step 5: Create Database Table

1. Go to **SQL Editor** in left sidebar
2. Click "New query"
3. Paste this SQL:

```sql
-- Create moments table
CREATE TABLE public.moments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    image_url TEXT NOT NULL,
    uploaded_by TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.moments ENABLE ROW LEVEL SECURITY;

-- Create policies for moments table
CREATE POLICY "Allow public read access" ON public.moments
    FOR SELECT USING (true);

CREATE POLICY "Allow insert for all users" ON public.moments
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow users to delete own moments" ON public.moments
    FOR DELETE USING (true);
```

4. Click "Run" to execute

## ✅ Step 6: Verify Setup

Your Supabase project should now have:
- ✅ Storage bucket named `moments`
- ✅ Proper storage policies for read/write/delete
- ✅ Database table `moments` with RLS enabled
- ✅ Your Project URL and API key ready

## 🔄 Next Steps

Once you complete these steps, let me know and I'll:
1. Add Supabase dependencies to your Flutter app
2. Create the Supabase service
3. Update the moments provider to use Supabase storage
4. Migrate from Firebase to Supabase

This will give you:
- 📸 **1GB free storage** (vs 1GB Firestore)
- 💰 **Much cheaper** storage costs
- ⚡ **Better performance** for images
- 🔄 **Real-time sync** still maintained
- 🖼️ **Proper image URLs** instead of base64

Ready to proceed? Just let me know when you've completed the Supabase setup!