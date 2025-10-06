# Quick FCM Setup Script
# Run this in PowerShell to set up Firebase Cloud Functions

Write-Host "🔔 Firebase Cloud Messaging Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if Firebase CLI is installed
Write-Host "Step 1: Checking Firebase CLI..." -ForegroundColor Yellow
$firebaseInstalled = Get-Command firebase -ErrorAction SilentlyContinue

if (-not $firebaseInstalled) {
    Write-Host "❌ Firebase CLI not found. Installing..." -ForegroundColor Red
    npm install -g firebase-tools
    Write-Host "✅ Firebase CLI installed!" -ForegroundColor Green
} else {
    Write-Host "✅ Firebase CLI found!" -ForegroundColor Green
}

Write-Host ""

# Step 2: Login to Firebase
Write-Host "Step 2: Logging into Firebase..." -ForegroundColor Yellow
Write-Host "⚠️  A browser window will open. Please login with your Google account." -ForegroundColor Cyan
firebase login

Write-Host ""

# Step 3: Initialize Functions
Write-Host "Step 3: Initializing Firebase Functions..." -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  When prompted, select:" -ForegroundColor Cyan
Write-Host "   - Use existing project: special-love-fa3eb" -ForegroundColor White
Write-Host "   - Language: TypeScript" -ForegroundColor White
Write-Host "   - ESLint: Yes" -ForegroundColor White
Write-Host "   - Install dependencies: Yes" -ForegroundColor White
Write-Host ""

$response = Read-Host "Ready to initialize? (y/n)"

if ($response -eq 'y') {
    firebase init functions
    
    Write-Host ""
    Write-Host "✅ Functions initialized!" -ForegroundColor Green
    Write-Host ""
    
    # Step 4: Copy template
    Write-Host "Step 4: Setting up function code..." -ForegroundColor Yellow
    
    if (Test-Path ".\functions\src\index.ts") {
        Copy-Item ".\cloud-function-template.ts" ".\functions\src\index.ts" -Force
        Write-Host "✅ Function code copied to functions/src/index.ts" -ForegroundColor Green
    } else {
        Write-Host "❌ Functions folder not found. Please run 'firebase init functions' first." -ForegroundColor Red
    }
    
    Write-Host ""
    
    # Step 5: Deploy
    Write-Host "Step 5: Ready to deploy!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To deploy your function, run:" -ForegroundColor Cyan
    Write-Host "   firebase deploy --only functions" -ForegroundColor White
    Write-Host ""
    Write-Host "⚠️  Note: You need the VAPID key first!" -ForegroundColor Yellow
    Write-Host "Get it from: Firebase Console → Project Settings → Cloud Messaging → Web Push certificates" -ForegroundColor Cyan
    Write-Host "Then add it to .env.local as:" -ForegroundColor Cyan
    Write-Host "   NEXT_PUBLIC_FIREBASE_VAPID_KEY=your-key-here" -ForegroundColor White
    
} else {
    Write-Host "Setup cancelled." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Get VAPID key from Firebase Console" -ForegroundColor White
Write-Host "2. Add to .env.local" -ForegroundColor White
Write-Host "3. Deploy function: firebase deploy --only functions" -ForegroundColor White
Write-Host "4. Rebuild app: npm run build" -ForegroundColor White
Write-Host "5. Test instant notifications! 🚀" -ForegroundColor White
Write-Host "=====================================" -ForegroundColor Cyan
