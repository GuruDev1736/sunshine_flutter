# API Key Troubleshooting Guide

## Issue: Image Load Failed & Routes Not Loading

### Common Problems:

## 1. ❌ "Image Load Failed - Check API key is enabled in Google Cloud Console"

### Root Cause:
The **Google Maps Static API** is not enabled in your Google Cloud Console.

### ✅ Step-by-Step Fix:

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/
   - Login with your Google account
   - Select your project: `sunshine-holiday-packages-1`

2. **Enable Static Maps API**
   - Go to: **APIs & Services** → **Library**
   - Search: `Maps Static API`
   - Click on it and press **ENABLE**

3. **Enable Directions API** (for routes)
   - Search: `Maps Directions API`
   - Click on it and press **ENABLE**

4. **Enable JavaScript Maps API**
   - Search: `Maps JavaScript API`
   - Click on it and press **ENABLE**

5. **Verify API Key Restrictions**
   - Go to: **APIs & Services** → **Credentials**
   - Click your API Key: `AIzaSyAMFUKLh_vAO6EKIHpR2pTLhjEeMdnEzUA`
   - Make sure under **API Restrictions** it says:
     - ✅ Maps Static API
     - ✅ Maps Directions API
     - ✅ Maps JavaScript API
     - Or: **Unrestricted** (allows all APIs)

---

## 2. ⟳ "Loading actual ground roads from Google Maps..." (Stuck)

### Root Causes:
- Directions API not enabled
- API quota exceeded
- Wrong API key
- Network connectivity issue

### ✅ Solutions:

#### Solution A: Check Console Logs
When you run the app, check the **Debug Console** for messages like:
```
============================================================
🗺️  GOOGLE DIRECTIONS API REQUEST
============================================================
API Key provided: true
API Key (masked): AIzaSy...UA
📍 Start: (19.0760, 78.9629)
📍 End: (19.1234, 72.8806)
🔗 Sending request to Google Directions API...
```

#### Solution B: Enable Directions API
1. Go to **Google Cloud Console** → **APIs & Services** → **Library**
2. Search: `Directions API`
3. Click and press **ENABLE**

#### Solution C: Check API Quota
1. Go to **APIs & Services** → **Quotas**
2. Find "Directions API"
3. Check if you have usage remaining (Most free tier has 25,000 requests/day)

#### Solution D: Restart the App
- Close the app completely
- Reopen it
- Wait 30 seconds for routes to load

---

## 3. 📱 Testing in Console

When you run the app, look for these console messages:

### ✅ SUCCESS State:
```
📸 DESTINATION IMAGE GENERATION
   Destination lat: 19.0760 (isNaN: false, isZero: false)
   Destination lng: 72.8806 (isNaN: false, isZero: false)
   API Key loaded: true
✓ Image loaded successfully

✓ Response received in 1247ms
✅ SUCCESS: Decoded 412 road coordinates
⏱️  Total time: 1345ms (1.35s)
🎯 Route displayed on map!
```

### ❌ FAIL States:
```
❌ CRITICAL: Google Maps API key is EMPTY!
   ⚙️ The Google Maps Static API may not be enabled
   ⚙️ Check: Google Cloud Console → APIs → Static Maps API → Enable

❌ API returned non-OK status: REQUEST_DENIED
   ⚙️ Check: API Key enabled in Google Cloud Console
   ⚙️ Check: Maps Directions API is enabled
   ⚙️ Check: API Key has correct restrictions/permissions

❌ API returned non-OK status: ZERO_RESULTS
   ⚙️ Routes not found between these locations
   ⚙️ Check coordinates are valid
```

---

## 4. 🔑 Verify Your API Key Configuration

### In `.env` file:
```env
GOOGLE_MAPS_API_KEY=AIzaSyAMFUKLh_vAO6EKIHpR2pTLhjEeMdnEzUA
```

### In `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyAMFUKLh_vAO6EKIHpR2pTLhjEeMdnEzUA"/>
```

### In `ios/Runner/Info.plist`:
```xml
<key>com.google.ios.maps.API_KEY</key>
<string>AIzaSyAMFUKLh_vAO6EKIHpR2pTLhjEeMdnEzUA</string>
```

✅ All three locations should have the same API key!

---

## 5. 🔄 Quick Fix Checklist:

- [ ] Go to Google Cloud Console
- [ ] Select: `sunshine-holiday-packages-1` project
- [ ] Go to APIs & Services → Library
- [ ] Search and **ENABLE**:
  - [ ] Maps Static API
  - [ ] Maps Directions API
  - [ ] Maps JavaScript API
- [ ] Go to APIs & Services → Credentials
- [ ] Click your API key
- [ ] Under "API Restrictions", select: **Unrestricted** (or select all 3 APIs above)
- [ ] Wait 5 minutes for changes to propagate
- [ ] Close and reopen the Flutter app
- [ ] Check Console logs for success messages

---

## 6. 📞 Still Having Issues?

Check these in order:
1. **Is internet working?** - Test by opening Google.com
2. **Is the API Key correct?** - Compare with `.env` file
3. **Are the APIs enabled?** - Check Google Cloud Console
4. **Is the API Key restricted?** - Make sure Maps APIs are allowed
5. **Have you waited 5 minutes?** - API changes take time to propagate
6. **Check Console Logs** - Copy the error message and troubleshoot

---

## Status Messages Meaning:

| Status | Meaning |
|--------|---------|
| ✓ Image loaded successfully | Destination image working fine |
| ✓ Response received in Xms | API call successful |
| ✅ SUCCESS: Decoded X coordinates | Routes loaded and displaying |
| ⟳ Loading actual ground roads | Waiting for API response |
| ❌ CRITICAL: API key is EMPTY | `.env` file not loaded properly |
| ❌ REQUEST_DENIED | API key not enabled in Google Cloud |
| ❌ ZERO_RESULTS | Route doesn't exist between locations |

---

Generated: 2026-02-18
