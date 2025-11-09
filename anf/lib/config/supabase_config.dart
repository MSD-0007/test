// 🔧 Supabase Configuration
// Follow SUPABASE_SETUP.md to get these values

class SupabaseConfig {
  // 📋 Replace with your Supabase project URL
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  
  // 🔑 Replace with your Supabase anon key
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
  
  // 🔥 Replace with your Firebase FCM Server Key
  static const String fcmServerKey = 'AAAA...your-fcm-server-key';
  
  // ✅ Set to true when you've configured the above values
  static const bool isConfigured = false;
}

// 📝 Instructions:
// 1. Create a free Supabase project at supabase.com
// 2. Follow the setup guide in SUPABASE_SETUP.md
// 3. Replace the values above with your actual credentials
// 4. Set isConfigured = true
// 5. Rebuild the app
//
// 🎉 Result: WhatsApp-like notifications that work even when app is closed!