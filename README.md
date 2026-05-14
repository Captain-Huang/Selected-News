# Selected News

Selected News is a cross-platform news app MVP based on Flutter + FastAPI.

- Client targets: Windows + Android (Web reserved)
- Backend: FastAPI + SQLite + RSS ingestion
- Fixed categories: AI / Tech / Finance / Events / Engineering
- No recommendation feed, no follow system

## Architecture

```text
Flutter App (apps/news_app)
    -> HTTP API
FastAPI Server (services/news_api)
    -> RSS fetch + filter + dedup
SQLite (news.db)
```

## Repository Structure

```text
Selected-News/
  apps/
    news_app/                 # Flutter client
  services/
    news_api/                 # FastAPI backend
  REQUIREMENTS.md             # Product/tech requirements
```

## Environment Requirements

### 1) Common

- Git
- Network access (for package downloads and RSS fetch)

### 2) Backend (FastAPI)

- Python 3.10+ (current verified: 3.14)
- pip

### 3) Flutter App

- Flutter SDK 3.41+ (current verified: 3.41.9)
- Dart (bundled with Flutter)

### 4) Build Android APK

- Android Studio (or Android SDK commandline tools)
- Android SDK + Platform tools
- Java/JDK (Android Studio bundled JBR is fine)

### 5) Build Windows EXE

- Windows 10/11
- Visual Studio 2022 with "Desktop development with C++"
- CMake/Ninja (normally handled by Flutter + VS)

## Backend Deployment (services/news_api)

### 1) Create and prepare venv

```powershell
cd G:\workspace\projects\Selected-News\services\news_api
python -m venv .venv
.venv\Scripts\python -m pip install --upgrade pip
.venv\Scripts\python -m pip install -r requirements.txt
```

### 2) Start server (foreground)

```powershell
cd G:\workspace\projects\Selected-News\services\news_api
.venv\Scripts\python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

### 3) Start server (background on Windows)

```powershell
cd G:\workspace\projects\Selected-News\services\news_api
start "news-api" /min cmd /c ".venv\Scripts\python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 1>uvicorn.out.log 2>uvicorn.err.log"
```

### 4) Health and API check

```powershell
curl http://127.0.0.1:8000/
curl http://127.0.0.1:8000/v1/categories
```

## Run App in Development (apps/news_app)

### 1) Install Flutter dependencies

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter pub get
```

### 2) Run on Windows

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### 3) Run on Android emulator

If backend runs on your local machine:

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter run -d android
```

The app defaults to `http://10.0.2.2:8000` on Android emulator.

### 4) Run on Android real device

Use your PC LAN IP:

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter run -d android --dart-define=API_BASE_URL=http://<YOUR_PC_IP>:8000
```

## Build Artifacts

### 1) Build Android APK

Debug APK:

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter build apk --debug
```

Output:

```text
apps/news_app/build/app/outputs/flutter-apk/app-debug.apk
```

Release APK:

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter build apk --release
```

### 2) Build Windows EXE

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter build windows --release
```

Output:

```text
apps/news_app/build/windows/x64/runner/Release/news_app.exe
```

## API Overview

- `GET /v1/categories`
- `GET /v1/news?category=AI&page=1&page_size=20&refresh=true`
- `GET /v1/sources?category_id=1`
- `POST /v1/sources`
- `PUT /v1/sources/{id}`
- `DELETE /v1/sources/{id}`

Response format:

```json
{
  "code": 0,
  "message": "ok",
  "data": {}
}
```

## Validation Commands

```powershell
# Backend syntax check
cd G:\workspace\projects\Selected-News\services\news_api
.venv\Scripts\python -m compileall app

# Flutter static checks
cd G:\workspace\projects\Selected-News\apps\news_app
flutter analyze
flutter test
```

## Notes

- `services/news_api/news.db` is local SQLite data file.
- If you change API host/port, pass `--dart-define=API_BASE_URL=...` when running/building app.
- First Windows build may be slow due to toolchain/plugin downloads.
