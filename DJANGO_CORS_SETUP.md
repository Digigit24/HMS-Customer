# Django Backend CORS Configuration for Flutter App

## 📱 Flutter App Configuration

### Step 1: Update Base URL in Flutter App

Edit `/lib/core/config/app_config.dart`:

```dart
// For LOCAL DEVELOPMENT (your computer)
static const String baseUrl = 'http://192.168.1.XXX:8000';  // Replace XXX with your IP

// For PRODUCTION (deployed backend)
static const String baseUrl = 'https://your-backend.com';

// For ANDROID EMULATOR (use special IP)
static const String baseUrl = 'http://10.0.2.2:8000';
```

### Step 2: Find Your Local IP Address

**Windows:**
```bash
ipconfig
# Look for "IPv4 Address" under your active network adapter
# Example: 192.168.1.100
```

**Mac/Linux:**
```bash
ifconfig
# or
ip addr
# Look for "inet" address
# Example: 192.168.1.100
```

**Important:** Use your computer's IP address, NOT `localhost` or `127.0.0.1`

---

## 🐍 Django Backend CORS Configuration

### Step 1: Install django-cors-headers

```bash
pip install django-cors-headers
pip freeze > requirements.txt  # Update requirements
```

### Step 2: Update Django settings.py

```python
# settings.py

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Add CORS headers BEFORE your apps
    'corsheaders',

    # Your apps
    'your_app',
    # ...
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',

    # Add CORS middleware at the TOP (very important!)
    'corsheaders.middleware.CorsMiddleware',

    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# CORS Configuration for Flutter App
CORS_ALLOWED_ORIGINS = [
    'http://localhost:3000',              # Web development
    'https://admin.gorehospital.com',     # Production web
    'http://192.168.1.100',               # Your local IP (replace with actual)
    'http://10.0.2.2:8000',               # Android emulator
]

# Or for development only (WARNING: Not secure for production!)
# CORS_ALLOW_ALL_ORIGINS = True

# Allow credentials (cookies, authorization headers)
CORS_ALLOW_CREDENTIALS = True

# Headers that your Flutter app sends
CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
    'x-tenant-id',          # Your custom headers
    'x-tenant-slug',        # Your custom headers
    'tenanttoken',          # Your custom headers
]

# HTTP methods allowed
CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]

# Allow these headers to be exposed to the browser
CORS_EXPOSE_HEADERS = [
    'Content-Type',
    'X-CSRFToken',
]
```

### Step 3: Additional Security Settings (Optional)

```python
# For development
DEBUG = True
ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '192.168.1.100',  # Your local IP
    'your-backend.com',  # Production domain
]

# For production
DEBUG = False
ALLOWED_HOSTS = [
    'your-backend.com',
]

# HTTPS settings (for production)
SECURE_SSL_REDIRECT = True  # Only in production
SESSION_COOKIE_SECURE = True  # Only in production
CSRF_COOKIE_SECURE = True  # Only in production
```

---

## 🔧 Request Headers Your Flutter App Sends

Your Flutter app automatically sends these headers (from `hms_dio_factory.dart`):

### Standard Headers:
```
Content-Type: application/json
Accept: application/json, text/plain, */*
Accept-Encoding: gzip, deflate, br, zstd
Accept-Language: en-US,en;q=0.9
Connection: keep-alive
Origin: https://admin.gorehospital.com
Referer: https://admin.gorehospital.com/
```

### Custom Headers (for multi-tenancy):
```
Authorization: Bearer <token>
x-tenant-id: <tenant_id>
x-tenant-slug: <tenant_slug>
tenanttoken: <tenant_token>
```

### Browser/Security Headers:
```
sec-fetch-dest: empty
sec-fetch-mode: cors
sec-fetch-site: cross-site
sec-ch-ua: "Google Chrome";v="143", "Chromium";v="143"
sec-ch-ua-mobile: ?1
sec-ch-ua-platform: "Android"
User-Agent: Mozilla/5.0 (Linux; Android 6.0...)
```

---

## 📝 Environment Variables (.env)

Create a `.env` file in your Django project:

```bash
# .env
DEBUG=True
SECRET_KEY=your-secret-key-here
DATABASE_URL=postgresql://user:pass@localhost/dbname

# CORS allowed origins (comma-separated)
CORS_ALLOWED_ORIGINS=http://localhost:3000,https://admin.gorehospital.com,http://192.168.1.100

# For development
ALLOWED_HOSTS=localhost,127.0.0.1,192.168.1.100

# For production
# ALLOWED_HOSTS=your-backend.com
```

Then in `settings.py`:

```python
import os
from dotenv import load_dotenv

load_dotenv()

DEBUG = os.getenv('DEBUG', 'False') == 'True'
SECRET_KEY = os.getenv('SECRET_KEY')
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '').split(',')
CORS_ALLOWED_ORIGINS = os.getenv('CORS_ALLOWED_ORIGINS', '').split(',')
```

---

## ✅ Testing CORS Configuration

### Test 1: Check Django Server
```bash
python manage.py runserver 0.0.0.0:8000
```

### Test 2: Test API endpoint from Flutter
1. Update `app_config.dart` with your IP
2. Run Flutter app
3. Check Django console for incoming requests

### Test 3: Verify CORS headers
Use browser DevTools or Postman to check response headers:
```
Access-Control-Allow-Origin: http://192.168.1.100
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS
```

---

## 🚀 Deployment Checklist

### For Production:

1. **Update Flutter app_config.dart:**
   ```dart
   static const String baseUrl = 'https://your-backend.com';
   static const String appOrigin = 'https://your-app.com';
   ```

2. **Update Django settings.py:**
   ```python
   DEBUG = False
   ALLOWED_HOSTS = ['your-backend.com']
   CORS_ALLOWED_ORIGINS = ['https://your-app.com']
   CORS_ALLOW_ALL_ORIGINS = False  # Never True in production!
   ```

3. **Rebuild Flutter APK:**
   ```bash
   flutter clean
   flutter build apk --release
   ```

---

## 🐛 Common Issues & Solutions

### Issue 1: "CORS policy: No 'Access-Control-Allow-Origin' header"
**Solution:** Add your Flutter app origin to `CORS_ALLOWED_ORIGINS` in Django settings

### Issue 2: App can't connect on physical device
**Solution:** Use your computer's IP address (192.168.x.x), not localhost

### Issue 3: Works in development but not production
**Solution:** Update `CORS_ALLOWED_ORIGINS` with production domain

### Issue 4: Custom headers blocked
**Solution:** Add custom headers to `CORS_ALLOW_HEADERS` in Django settings

### Issue 5: OPTIONS preflight requests failing
**Solution:** Ensure `corsheaders.middleware.CorsMiddleware` is FIRST in MIDDLEWARE

---

## 📞 Support

If you encounter issues:
1. Check Django console for CORS errors
2. Check Flutter app logs (flutter logs)
3. Verify network connectivity: `ping 192.168.1.XXX`
4. Test API with Postman/curl first
5. Verify Django CORS middleware is installed and configured

---

**Important Security Notes:**
- Never use `CORS_ALLOW_ALL_ORIGINS = True` in production
- Always use HTTPS in production
- Keep `DEBUG = False` in production
- Never commit `.env` file to git (add to `.gitignore`)
