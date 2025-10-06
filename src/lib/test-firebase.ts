import { db } from '@/lib/firebase';
import { collection, addDoc, serverTimestamp, getDocs } from 'firebase/firestore';

// TEST FIREBASE CONNECTION
export async function testFirebaseConnection() {
  console.log('🧪 Testing Firebase connection...');
  
  try {
    // Test 1: Check if db exists
    console.log('✓ Firebase db object exists:', !!db);
    
    // Test 2: Try to read existing pings
    console.log('📖 Attempting to read pings collection...');
    const pingsSnapshot = await getDocs(collection(db, 'pings'));
    console.log('✓ Pings collection exists. Documents:', pingsSnapshot.size);
    
    pingsSnapshot.forEach((doc) => {
      console.log('  - Ping:', doc.id, doc.data());
    });
    
    // Test 3: Try to write a test ping
    console.log('📝 Attempting to write test ping...');
    const testPing = {
      type: 'test',
      from: 'test-sender',
      to: 'test-receiver',
      message: 'This is a test ping',
      emoji: '🧪',
      timestamp: serverTimestamp(),
      read: false
    };
    
    const docRef = await addDoc(collection(db, 'pings'), testPing);
    console.log('✅ Test ping written successfully! Doc ID:', docRef.id);
    
    return {
      success: true,
      message: 'All tests passed!',
      docId: docRef.id
    };
    
  } catch (error: any) {
    console.error('❌ Firebase test FAILED:', error);
    console.error('Error code:', error.code);
    console.error('Error message:', error.message);
    
    return {
      success: false,
      error: error.message,
      code: error.code
    };
  }
}
