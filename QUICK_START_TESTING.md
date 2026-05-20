# 🚀 EduConnect Mobile - Quick Start Guide

## ⚡ 5-Minute Setup

### Prerequisites
- Flutter 3.11.3+ installed
- .NET SDK 7+ installed
- Chrome browser (for web testing)

### Step 1: Start the Backend (30 seconds)

```powershell
cd "c:\Users\Yoni\Documents\GitHub\Educonnect-MobileSide\EduConnect-Backend"
dotnet run
```

**Expected output:**
```
Now listening on: http://localhost:5001
Application started. Press Ctrl+C to shut down.
```

✅ Backend is ready!

---

### Step 2: Start the Flutter App (1 minute)

**Open a NEW terminal and run:**

```powershell
cd "c:\Users\Yoni\Documents\GitHub\Educonnect-MobileSide"
flutter run -d chrome
```

**Expected output:**
```
Launching lib\main.dart on Chrome in debug mode...
...
Flutter run key commands.
r Hot reload.
R Hot restart.
```

✅ App will open automatically in Chrome!

---

## 🧪 What to Test

### 1. Authentication Flow (2 min)
1. Click **"Sign Up"** button
2. Enter:
   - Full Name: `Test User`
   - Email: `test@example.com`
   - Password: `TestPassword123!` (must have uppercase, lowercase, number, special char)
3. Click **"Sign Up"**
4. Login screen appears ✅
5. Enter email and password
6. Click **"Log In"** ✅

### 2. Browse Courses (1 min)
1. After login, you're on **Browse** tab
2. See grid of published courses from backend
3. Tap any course → **Course Detail** screen opens ✅

### 3. Course Detail (1 min)
1. See course info: title, category, instructor, description
2. Click module to expand and see lessons
3. Lessons show materials (article, video, file, image)
4. Click **"Enroll"** button ✅

### 4. Enrollment Flow (1 min)
1. Payment dialog appears showing course price
2. Click **"Proceed"** to enroll
3. Dialog closes, button changes to "Enrolled" ✅
4. Go to **"My Courses"** tab
5. See your enrolled course in the list ✅

### 5. Live Sessions (30 sec)
1. From course detail, scroll to **"Live Sessions"**
2. See upcoming sessions (if InstructorLed course)
3. Sessions show date, time, and status ✅

---

## 🔧 Hot Reload (Active Development)

During development, you can edit code and see changes instantly:

```powershell
# In the running flutter terminal, press 'r' to hot reload
r  # Hot reload (fast, keeps app state)
R  # Hot restart (slow, resets app state)
q  # Quit
```

**Example**: Edit `lib/presentation/screens/browse_screen.dart`, press `r`, changes appear in 1 second!

---

## 📱 Testing on Android Emulator

```powershell
# List available emulators
flutter emulators

# Launch Pixel 7
flutter emulators --launch Pixel_7

# In new terminal, run Flutter
flutter run -d Pixel_7
```

⚠️ **Note**: Android emulator uses `http://10.0.2.2:5001` instead of localhost

---

## 🆘 Troubleshooting

### Backend Won't Start
```powershell
# Check if port 5001 is in use
netstat -ano | findstr "5001"

# If in use, kill the process
taskkill /PID <PID> /F
```

### Flutter Can't Find Chrome
```powershell
# Make sure Chrome is installed and run:
flutter run -d chrome --web-renderer html
```

### Hot Reload Not Working
```powershell
# Do a full restart
R  # In the running terminal

# Or stop and restart
q  # Quit
flutter run -d chrome
```

### API Connection Error
1. **Check backend is running**: `netstat -ano | findstr "5001"`
2. **Test API directly**:
   ```powershell
   Invoke-WebRequest -Uri http://localhost:5001/api/Course/published
   ```
3. **Clear cache**:
   ```powershell
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

---

## 📊 Verification Checklist

- [ ] Backend running on localhost:5001
- [ ] Flutter app open in Chrome
- [ ] Can create new account via signup
- [ ] Can login with created account
- [ ] Browse tab shows courses
- [ ] Can tap course and see details
- [ ] Can enroll in course (payment dialog works)
- [ ] My Courses tab shows enrolled course
- [ ] Live Sessions section appears (for InstructorLed courses)
- [ ] Hot reload works (edit file, press 'r')

---

## 💡 Useful Commands

```powershell
# Analyze code
flutter analyze

# Build for web (production)
flutter build web

# Build for Android (APK)
flutter build apk

# Get all dependencies
flutter pub get

# Upgrade dependencies (carefully!)
flutter pub upgrade

# Check Flutter setup
flutter doctor

# View device logs
flutter logs
```

---

## 🎯 Next Steps After Testing

1. **Test on Android device**: Connect real phone and run `flutter run`
2. **Test payment**: Integrate real Chapa API
3. **Test video playback**: Upload course videos to backend
4. **Collect user feedback**: Share APK with beta users
5. **Deploy to Play Store**: Generate signed APK

---

## 📞 Support

If something breaks:
1. **Check logs**: `flutter logs`
2. **Clean build**: `flutter clean && flutter pub get`
3. **Restart backend**: Ctrl+C in backend terminal, then `dotnet run`
4. **Check network**: `netstat -ano | findstr "5001"`

---

**Happy testing! 🚀**

*If everything works, you have a fully functional course learning app!*
