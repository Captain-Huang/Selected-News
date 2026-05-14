# Selected News

Language: [中文](#中文) | [English](#english)

---

## 中文

<details open>
<summary>点击收起/展开中文内容</summary>

### 项目简介

Selected News 是一个基于 Flutter + FastAPI 的跨平台新闻 App MVP。

- 客户端：Windows + Android（Web 预留）
- 服务端：FastAPI + SQLite + RSS 抓取
- 固定分类：AI / 科技 / 财经 / 事件 / 技术
- 不做推荐流、不做关注体系

### 架构

```text
Flutter App (apps/news_app)
    -> HTTP API
FastAPI Server (services/news_api)
    -> RSS fetch + filter + dedup
SQLite (news.db)
```

### 目录结构

```text
Selected-News/
  apps/
    news_app/                 # Flutter 客户端
  services/
    news_api/                 # FastAPI 服务端
  REQUIREMENTS.md             # 需求文档
```

### 环境要求

1. 通用
- Git
- 可访问网络（下载依赖、抓取 RSS）

2. 服务端
- Python 3.10+（当前验证 3.14）
- pip

3. 客户端
- Flutter SDK 3.41+（当前验证 3.41.9）
- Dart（Flutter 自带）

4. Android 构建
- Android Studio 或 Android SDK CLI
- Android SDK + Platform Tools
- Java/JDK（Android Studio 自带可用）

5. Windows EXE 构建
- Windows 10/11
- Visual Studio 2022（Desktop development with C++）
- CMake/Ninja（通常由 Flutter + VS 处理）

### Server 部署（services/news_api）

1. 创建并准备虚拟环境

```powershell
cd G:\workspace\projects\Selected-News\services\news_api
python -m venv .venv
.venv\Scripts\python -m pip install --upgrade pip
.venv\Scripts\python -m pip install -r requirements.txt
```

2. 前台启动

```powershell
cd G:\workspace\projects\Selected-News\services\news_api
.venv\Scripts\python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

3. Windows 后台启动

```powershell
cd G:\workspace\projects\Selected-News\services\news_api
start "news-api" /min cmd /c ".venv\Scripts\python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 1>uvicorn.out.log 2>uvicorn.err.log"
```

4. 健康检查

```powershell
curl http://127.0.0.1:8000/
curl http://127.0.0.1:8000/v1/categories
```

### App 运行（apps/news_app）

1. 安装依赖

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter pub get
```

2. Windows 运行

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

3. Android 模拟器运行

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter run -d android
```

说明：Android 模拟器默认使用 `http://10.0.2.2:8000`。

4. Android 真机运行

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter run -d android --dart-define=API_BASE_URL=http://<YOUR_PC_IP>:8000
```

### 构建产物

1. Android APK

Debug:

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter build apk --debug
```

输出：

```text
apps/news_app/build/app/outputs/flutter-apk/app-debug.apk
```

Release:

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter build apk --release
```

2. Windows EXE

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter build windows --release
```

输出：

```text
apps/news_app/build/windows/x64/runner/Release/news_app.exe
```

### API 概览

- `GET /v1/categories`
- `GET /v1/news?category=AI&page=1&page_size=20&refresh=true`
- `GET /v1/sources?category_id=1`
- `POST /v1/sources`
- `PUT /v1/sources/{id}`
- `DELETE /v1/sources/{id}`

统一响应：

```json
{
  "code": 0,
  "message": "ok",
  "data": {}
}
```

### 验证命令

```powershell
# 后端
cd G:\workspace\projects\Selected-News\services\news_api
.venv\Scripts\python -m compileall app

# Flutter
cd G:\workspace\projects\Selected-News\apps\news_app
flutter analyze
flutter test
```

</details>

---

## English

<details>
<summary>Click to expand English content</summary>

### Overview

Selected News is a cross-platform news app MVP based on Flutter + FastAPI.

- Client targets: Windows + Android (Web reserved)
- Backend: FastAPI + SQLite + RSS ingestion
- Fixed categories: AI / Tech / Finance / Events / Engineering
- No recommendation feed, no follow system

### Architecture

```text
Flutter App (apps/news_app)
    -> HTTP API
FastAPI Server (services/news_api)
    -> RSS fetch + filter + dedup
SQLite (news.db)
```

### Repository Structure

```text
Selected-News/
  apps/
    news_app/                 # Flutter client
  services/
    news_api/                 # FastAPI backend
  REQUIREMENTS.md             # Product/tech requirements
```

### Environment Requirements

1. Common
- Git
- Network access (for package downloads and RSS fetch)

2. Backend
- Python 3.10+ (verified with 3.14)
- pip

3. Flutter
- Flutter SDK 3.41+ (verified with 3.41.9)
- Dart (bundled with Flutter)

4. Android build
- Android Studio or Android SDK CLI
- Android SDK + Platform tools
- Java/JDK (Android Studio bundled JBR works)

5. Windows EXE build
- Windows 10/11
- Visual Studio 2022 with "Desktop development with C++"
- CMake/Ninja (usually managed by Flutter + VS)

### Server Deployment (services/news_api)

1. Create and prepare venv

```powershell
cd G:\workspace\projects\Selected-News\services\news_api
python -m venv .venv
.venv\Scripts\python -m pip install --upgrade pip
.venv\Scripts\python -m pip install -r requirements.txt
```

2. Start in foreground

```powershell
cd G:\workspace\projects\Selected-News\services\news_api
.venv\Scripts\python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

3. Start in background (Windows)

```powershell
cd G:\workspace\projects\Selected-News\services\news_api
start "news-api" /min cmd /c ".venv\Scripts\python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 1>uvicorn.out.log 2>uvicorn.err.log"
```

4. Health check

```powershell
curl http://127.0.0.1:8000/
curl http://127.0.0.1:8000/v1/categories
```

### App Run (apps/news_app)

1. Install dependencies

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter pub get
```

2. Run on Windows

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

3. Run on Android emulator

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter run -d android
```

Note: Android emulator defaults to `http://10.0.2.2:8000`.

4. Run on Android physical device

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter run -d android --dart-define=API_BASE_URL=http://<YOUR_PC_IP>:8000
```

### Build Artifacts

1. Android APK

Debug:

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter build apk --debug
```

Output:

```text
apps/news_app/build/app/outputs/flutter-apk/app-debug.apk
```

Release:

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter build apk --release
```

2. Windows EXE

```powershell
cd G:\workspace\projects\Selected-News\apps\news_app
flutter build windows --release
```

Output:

```text
apps/news_app/build/windows/x64/runner/Release/news_app.exe
```

### API Overview

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

### Validation Commands

```powershell
# Backend
cd G:\workspace\projects\Selected-News\services\news_api
.venv\Scripts\python -m compileall app

# Flutter
cd G:\workspace\projects\Selected-News\apps\news_app
flutter analyze
flutter test
```

</details>
