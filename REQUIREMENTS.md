# Selected News 跨平台新闻 App 需求文档

## 1. 项目背景与目标

### 1.1 背景
需要开发一款跨平台新闻聚合 App，首期支持 Windows 与 Android，后续可扩展到 Web。产品定位为“固定分类 + 多来源聚合 + 可配置筛选”，不做个性化推荐流与关注体系。

### 1.2 目标
1. 构建稳定可用的新闻聚合 MVP。
2. 支持按分类配置数据源网站。
3. 提供统一新闻列表与详情阅读体验。
4. 保证后续扩展性（新增分类、来源、平台）。

### 1.3 非目标（首期不做）
1. 不做推荐算法与用户画像。
2. 不做关注/粉丝/社交互动。
3. 不做复杂内容生产（如自动改写正文）。

## 2. 平台与技术选型

### 2.1 客户端
1. 框架：Flutter
2. 首期平台：Windows、Android
3. 后续平台：Web（预留）

### 2.2 后端（推荐）
1. 聚合服务：FastAPI（或 Node.js，首选 FastAPI）
2. 数据库：SQLite（MVP）-> PostgreSQL（扩展）
3. 定时任务：APScheduler / Celery（按复杂度升级）

### 2.3 架构原则
客户端不直接抓取网站页面。抓取、解析、筛选、去重统一在后端完成，客户端只消费标准化 API。

## 3. 信息架构与核心流程

### 3.1 固定分类页签
1. AI
2. 科技
3. 财经
4. 事件
5. 技术

### 3.2 业务主流程
1. App 启动 -> 请求分类列表与对应新闻。
2. 后端按分类读取已启用数据源并抓取/读取缓存。
3. 后端执行筛选规则、去重、排序，返回统一结构。
4. 客户端展示列表，支持下拉刷新与分页加载。
5. 用户点击新闻进入详情（WebView 或内置阅读页）。

## 4. 功能需求

### 4.1 新闻列表页
1. 顶部固定分类 Tab。
2. 每个 Tab 独立数据流与滚动状态。
3. 新闻卡片字段：标题、来源、发布时间、摘要、封面图（可缺省）。
4. 支持下拉刷新、上拉加载更多。
5. 支持加载中、空状态、错误重试。

### 4.2 新闻详情页
1. 首期采用 WebView 打开原文。
2. 保留后续扩展：提取正文形成阅读模式。

### 4.3 数据源配置页
1. 以分类维度管理来源站点。
2. 支持新增/编辑/删除来源。
3. 支持启用/禁用来源。
4. 支持来源类型字段（`rss` / `api` / `html`）。

### 4.4 设置页
1. 刷新策略（启动刷新、手动刷新）。
2. 网络策略（仅 Wi-Fi 刷新可选）。
3. 缓存管理（清理缓存）。
4. 深色模式（可选，MVP 可后置）。

## 5. 筛选规则与排序

### 5.1 规则模型
每个分类允许配置：
1. `include_keywords`：命中关键词才保留。
2. `exclude_keywords`：命中关键词则剔除。
3. `source_weight`：来源权重（可选）。
4. `time_window`：时间窗口（如仅最近 24h/7d）。

### 5.2 去重规则
1. 首选 `url` 去重。
2. 其次 `title + source` 归一化后去重。
3. 保留发布时间更新或评分更高的一条。

### 5.3 排序规则（MVP）
按发布时间倒序，辅以来源权重微调。

## 6. 数据模型（建议）

### 6.1 Category
- `id`
- `name`（AI/科技/财经/事件/技术）
- `sort_order`
- `enabled`

### 6.2 Source
- `id`
- `category_id`
- `name`
- `base_url`
- `type`（rss/api/html）
- `enabled`
- `parser_config`（JSON，可选）
- `created_at`
- `updated_at`

### 6.3 NewsItem
- `id`
- `category_id`
- `source_id`
- `title`
- `summary`
- `url`
- `cover_image`
- `published_at`
- `fetched_at`
- `tags`（JSON，可选）
- `score`（可选）
- `dedup_hash`

## 7. API 设计（MVP）

1. `GET /v1/categories`
2. `GET /v1/news?category=AI&page=1&page_size=20`
3. `POST /v1/sources`
4. `PUT /v1/sources/{id}`
5. `DELETE /v1/sources/{id}`
6. `POST /v1/fetch/trigger`（手动触发抓取，可选）

响应统一包含：
- `code`
- `message`
- `data`

## 8. Flutter 客户端实现建议

1. 状态管理：Riverpod（或 Bloc，二选一）
2. 网络请求：Dio
3. 路由：go_router
4. 本地缓存：Hive 或 Drift
5. 图片缓存：cached_network_image
6. WebView：webview_flutter

目录建议：
- `lib/features/news/`
- `lib/features/source_config/`
- `lib/features/settings/`
- `lib/core/network/`
- `lib/core/storage/`

## 9. 迭代里程碑

### 阶段 1：UI 与骨架
1. 搭建 Flutter 工程（Windows + Android）。
2. 完成五个固定 Tab 与列表 UI。
3. 接入 Mock 数据，打通刷新与分页。

### 阶段 2：后端聚合最小可用
1. 建立 FastAPI 服务与 SQLite。
2. 实现分类、来源、新闻接口。
3. 接入 RSS 解析并返回真实数据。

### 阶段 3：规则与稳定性
1. 实现关键词筛选与去重。
2. 增加抓取日志与错误监控。
3. 优化缓存与性能。

### 阶段 4：体验增强
1. 详情阅读增强。
2. 搜索与标签扩展。
3. Web 端适配准备。

## 10. 验收标准（MVP）

1. Windows 与 Android 均可启动并正常浏览五类新闻。
2. 每类可独立配置来源且配置生效。
3. App 启动后可拉取数据并展示。
4. 同源重复新闻不会重复出现（满足基础去重）。
5. 网络异常时有明确错误提示与重试入口。

## 11. 风险与应对

1. 网站结构变更导致解析失效：
优先采用 RSS/API，HTML 解析作为补充。

2. 反爬与访问频率限制：
使用缓存与轮询策略，控制抓取频率。

3. 多平台一致性问题：
统一后端数据协议，客户端只做渲染与交互。

4. 后续扩展复杂度：
通过 `source.type + parser_config` 保持数据源扩展能力。
