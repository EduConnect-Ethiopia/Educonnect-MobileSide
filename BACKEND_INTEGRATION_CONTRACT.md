# Backend ↔ Mobile API Integration Contract
## Commit 4: Mobile-Backend Integration & Authentication Foundation

**Document Version:** 1.0  
**Last Updated:** 2026-05-17  
**Status:** ✅ READY FOR INTEGRATION TESTING

---

## 📡 Communication Protocol

### Base URL
```
Development: http://10.0.2.2:5001
Production:  https://api.educonnect.et (from .env.prod)
```

### Content Type
```
All requests:  Content-Type: application/json
All responses: Content-Type: application/json
```

### Timeout Configuration
```
Connect Timeout: 30 seconds (30000ms)
Receive Timeout: 30 seconds (30000ms)
```

---

## 🔐 Authentication Flow

### 1. SIGNUP (Register New User)

**Mobile → Backend**
```http
POST /api/Auth/signup
Content-Type: application/json

{
  "fullName": "John Doe",
  "email": "john.doe@example.com",
  "password": "SecurePassword123!",
  "phoneNumber": "+251911234567"        // Optional
}
```

**Backend → Mobile (Success 200)**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "fullName": "John Doe",
    "email": "john.doe@example.com"
  }
}
```

**Mobile Action:**
1. Extracts registration success
2. Auto-logs in using provided credentials
3. If auto-login fails: Shows "Account created. Please sign in." and navigates to LoginScreen
4. If auto-login succeeds: Navigates to MainNavigationScreen

**Backend → Mobile (Error 400)**
```json
{
  "success": false,
  "message": "Email already exists",
  "errors": {}
}
```

**Mobile Error Handling:**
- Displays message in SnackBar
- Keeps user on RegisterScreen
- User can retry with different email

---

### 2. LOGIN (Authenticate User)

**Mobile → Backend**
```http
POST /api/Auth/login
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "password": "SecurePassword123!"
}
```

**Backend → Mobile (Success 200)**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZTg4YzgzMGMwZDEyMzQ1Njc4OTBhYmMiLCJlbWFpbCI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIiwibmFtZSI6IkpvaG4gRG9lIn0.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userId": "5e88c830c0d12345678900abc",
    "fullName": "John Doe",
    "email": "john.doe@example.com",
    "expiresAt": "2026-05-17T16:30:00Z"
  }
}
```

**Mobile Action:**
1. Extracts JWT token from `data.token`
2. Stores in SharedPreferences via `TokenStorage.saveTokens()`
3. Stores user data (userId, fullName, email) via `TokenStorage.saveUser()`
4. Creates `AuthSession` object with all data
5. Updates `AuthState` to authenticated
6. Navigates to MainNavigationScreen

**Backend → Mobile (Error 401)**
```json
{
  "success": false,
  "message": "Invalid email or password",
  "errors": {}
}
```

**Mobile Error Handling:**
- Displays "Invalid email or password."
- Keeps user on LoginScreen
- User can retry

---

### 3. JWT TOKEN STORAGE

**Mobile Storage Implementation:**
```dart
TokenStorage (wrapper around SharedPreferences)
├── auth.access_token        → JWT token string
├── auth.refresh_token       → Refresh token (optional)
├── auth.expires_at          → Token expiry datetime ISO string
├── auth.user_id             → User UUID
├── auth.user_email          → User email
└── auth.user_full_name      → User full name
```

**Automatic Token Attachment:**
```
JwtAuthInterceptor automatically adds to all requests:

Headers:
{
  "Authorization": "Bearer eyJhbGci..."
}

Exception: Auth endpoints skip Authorization header:
- /api/Auth/signup
- /api/Auth/login
- /api/Auth/forgot-password
- /api/Auth/verify-reset-code
- /api/Auth/reset-password
```

---

### 4. LOGOUT (Clear Session)

**Mobile → Backend**
```
No backend call needed!
Mobile clears all stored data locally via TokenStorage.clear()
```

**Mobile Action:**
1. Calls `AuthController.signOut()`
2. Calls `AuthRepository.logout()`
3. Calls `TokenStorage.clear()`
4. Updates `AuthState` to unauthenticated
5. Navigates to LoginScreen

**Token Cleanup:**
```dart
// All SharedPreferences keys removed:
- auth.access_token
- auth.refresh_token
- auth.expires_at
- auth.user_id
- auth.user_email
- auth.user_full_name
```

---

## 🔄 Session Management

### Session Restoration (App Restart)

**Mobile Startup Flow:**
```
1. App starts → SplashScreen displayed
2. appStartupProvider.watch() triggers
3. AuthRepository.isAuthenticated() checked
4. If hasValidSession = true:
   - AuthRepository.getStoredSession() retrieves from storage
   - Returns AuthSession with stored token + user data
   - SplashScreen navigates to MainNavigationScreen
   - User remains logged in ✅
5. If hasValidSession = false:
   - No stored token or token expired
   - SplashScreen navigates to LoginScreen
   - User must login again
```

**Token Expiry Check:**
```dart
DateTime.now().isBefore(expiresAt.toUtc())
```

If token expired:
- Treated as no session
- User redirected to LoginScreen
- Can implement refresh token flow in future

---

### Unauthorized Response Handling

**Backend → Mobile (401 Unauthorized)**
```http
HTTP/1.1 401 Unauthorized
Content-Type: application/json

{
  "success": false,
  "message": "Token has expired",
  "errors": {}
}
```

**Mobile Action (JwtAuthInterceptor):**
```dart
@override
Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode == 401 &&
      !_isAuthEndpoint(err.requestOptions.path)) {
    // Clear all stored auth data
    await _tokenStorage.clear();
    
    // UI will detect unauthenticated state
    // App will redirect to LoginScreen
  }
  handler.next(err);
}
```

---

## 🔑 Error Handling Strategy

### Mobile Error Translation

**1. DioException → User-Friendly Message**

| Error Type | Message Shown |
|------------|---------------|
| Connection Timeout | "The connection timed out. Please try again." |
| Receive Timeout | "The connection timed out. Please try again." |
| Send Timeout | "The connection timed out. Please try again." |
| 401 Unauthorized | "Invalid email or password." |
| No Internet | "Unable to reach EduConnect. Please try again." |
| Generic Exception | "Something went wrong. Please try again." |

**2. Backend Error Messages**
```json
{
  "success": false,
  "message": "Email already exists",
  "errors": {}
}
```

Mobile extracts `message` field and displays to user.

**3. SnackBar Display**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(errorMessage))
);
```

---

## 📱 API Endpoints Used in Commit 4

### Auth Endpoints
| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `/api/Auth/signup` | POST | ❌ | Register new user |
| `/api/Auth/login` | POST | ❌ | Authenticate user |
| `/api/Auth/forgot-password` | POST | ❌ | Request password reset |
| `/api/Auth/verify-reset-code` | POST | ❌ | Verify reset code |
| `/api/Auth/reset-password` | POST | ❌ | Complete password reset |

### Future Endpoints (For Commit 5+)
| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `/api/Course/published` | GET | ✅ | List public courses |
| `/api/Course/{courseId}/content` | GET | ✅ | Get course details |
| `/api/Enrollment/enroll` | POST | ✅ | Enroll in course |
| `/api/Enrollment/me` | GET | ✅ | Get user's enrollments |
| `/api/Enrollment/unenroll` | DELETE | ✅ | Drop course |
| `/api/CourseSession/{courseId}` | GET | ✅ | Get sessions |

---

## 🧪 Testing Checklist

### Unit Tests
- [ ] `AuthLocalDataSource.saveAuthData()` and `getAccessToken()`
- [ ] `AuthRemoteDataSource.login()` with mock Dio
- [ ] `AuthRepositoryImpl.login()` flow
- [ ] `TokenStorage` serialization/deserialization
- [ ] `AuthUser.fromJson()` with various backend responses
- [ ] Error message formatting in `AuthController._friendlyError()`

### Integration Tests
- [ ] Complete signup flow: RegisterScreen → AuthController → Remote → Storage → MainScreen
- [ ] Complete login flow: LoginScreen → AuthController → Remote → Storage → MainScreen
- [ ] Session restoration: App start → SplashScreen → Storage check → MainScreen
- [ ] Logout flow: LogoutButton → Clear storage → LoginScreen
- [ ] 401 handling: Unauthorized response → Storage cleared → LoginScreen

### Manual Testing (Real Device/Emulator)
- [ ] Signup with new email → Auto-login → Verify in MainScreen
- [ ] Logout → Back to LoginScreen
- [ ] Close app completely
- [ ] Restart app → Verify auto-login (session restoration)
- [ ] Change password on backend
- [ ] Try login with old password → 401 error handling
- [ ] Try login with wrong email → Error message
- [ ] Timeout behavior (disconnect internet, try login)
- [ ] App icon displays correctly on home screen

---

## 🚀 Deployment Checklist

### Before Release
- [ ] Backend running on correct IP/Port (10.0.2.2:5001 for emulator)
- [ ] Production backend URL in `.env.prod`
- [ ] Keystore configured for Android signing
- [ ] Provisioning profiles set for iOS
- [ ] App icon generated with `flutter_launcher_icons`
- [ ] All dependencies resolved: `flutter pub get`
- [ ] No analysis errors: `flutter analyze`
- [ ] Tests passing: `flutter test`
- [ ] Build successful: `flutter build apk` and `flutter build ios`

### Firebase (Configured in Previous Commits)
- [ ] Firebase Analytics integrated
- [ ] Firebase Messaging integrated
- [ ] Google Services configured

---

## 📋 Response Format Expectations

### Success Response Template
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    // Endpoint-specific data
  }
}
```

### Error Response Template
```json
{
  "success": false,
  "message": "Error description",
  "errors": {
    "fieldName": ["Error for this field"]
  }
}
```

### Mobile Parsing Logic
```dart
// In AuthResponse.fromJson()
final data = findMap(json, const ['data', 'result']) ?? json;

// Searches for nested data in:
// 1. json['data']
// 2. json['result']
// 3. Falls back to json itself

// Field extraction uses multiple keys:
final token = findString(data, const ['token', 'accessToken', 'jwt']);
```

---

## ⚙️ Configuration Reference

### Environment Variables (.env.dev)
```
APP_FLAVOR=dev
APP_NAME=EduConnect Ethiopia Dev
API_BASE_URL=http://10.0.2.2:5001
API_CONNECT_TIMEOUT_MS=30000
API_RECEIVE_TIMEOUT_MS=30000
```

### App Bootstrap
```dart
// Loads .env.dev into flutter_dotenv
await dotenv.load(fileName: AppEnvironment.envFileName);

// Creates SharedPreferences and passes to DI
final prefs = await SharedPreferences.getInstance();

// Creates DioClient with JWT interceptor
final dio = DioClient.create(tokenStorage: tokenStorage);
```

---

## 📞 Troubleshooting Integration Issues

### "Unable to reach EduConnect" Error
**Solution:** Verify backend is running on `http://10.0.2.2:5001`
- Check Android emulator has internet access
- Verify backend port is 5001 (not 5000)
- Check firewall isn't blocking connections

### Token Not Persisting
**Solution:** Ensure SharedPreferences is working
```bash
flutter pub get
flutter clean
flutter run
```

### 401 Unauthorized After Successful Login
**Solution:** Check JWT token format
- Backend must return token in `data.token` field
- Mobile must extract and store it correctly
- Verify token is being attached: Check logs with `LogInterceptor`

### Session Lost on App Restart
**Solution:** Check session restoration logic
- Verify `TokenStorage.hasValidSession` returns true
- Check token expiry datetime is set
- Verify `appStartupProvider` is called

### Login Works But Can't Access Other Endpoints
**Solution:** Check JWT interceptor
```dart
// Enable logging to see headers:
if (AppEnvironment.isDev) {
  dio.interceptors.add(LogInterceptor(requestBody: true));
}
```

---

## 🔄 Future Enhancement Paths

**Phase 2 (Commit 5):**
- Course catalog browsing
- Course enrollment
- Course content display

**Phase 3 (Commit 6+):**
- Video playback
- Material downloads
- Progress tracking
- Session attendance
- Certificate generation

---

**Document Owner:** Commit 4 Implementation  
**Review Date:** Pre-Release Testing  
**Next Review:** After integration testing with backend  
