# Selected News 开发执行 Prompt（可直接投喂）

你现在是我的资深全栈工程搭档，请基于当前项目根目录下的 `REQUIREMENTS.md` 实现一个跨平台新闻 App 的 MVP。

## 目标
使用 Flutter + FastAPI 完成一个“固定分类、多来源聚合、可配置筛选”的新闻应用，首期支持 Windows 与 Android，且架构上兼容后续 Web 扩展。

## 硬性约束
1. 必须严格对齐 `REQUIREMENTS.md`，不要擅自新增复杂功能。
2. 不实现推荐流，不实现关注体系。
3. 客户端不直接抓网站；抓取和筛选放在后端。
4. 所有新增代码要可运行，优先保证 MVP 可用。
5. 每次改动后给出“改了什么 + 为什么 + 如何验证”。

## 开发范围

### A. Flutter 客户端（Windows + Android）
1. 实现固定 Tab：AI、科技、财经、事件、技术。
2. 实现新闻列表页：标题、来源、时间、摘要、封面图。
3. 支持下拉刷新、加载更多、空状态、错误重试。
4. 实现新闻详情页（WebView 打开原文）。
5. 预留来源配置页与设置页骨架（最小可用）。

建议技术：
- 状态管理：Riverpod
- 网络：Dio
- 路由：go_router
- 本地缓存：Hive（或 Drift）

### B. FastAPI 后端
1. 建立基础工程与 `v1` 路由。
2. 实现数据模型：Category、Source、NewsItem。
3. 提供接口：
   - `GET /v1/categories`
   - `GET /v1/news`
   - `POST /v1/sources`
   - `PUT /v1/sources/{id}`
   - `DELETE /v1/sources/{id}`
4. 接入 RSS 抓取（先支持 RSS，HTML/API 可后置）。
5. 实现基础筛选：
   - include/exclude keywords
   - url/title 去重
   - 发布时间倒序

建议技术：
- FastAPI + SQLAlchemy + SQLite
- feedparser（RSS）

## 执行方式
请按以下顺序执行，不要跳步：

1. 先输出项目目录规划（客户端与后端）。
2. 再搭建后端最小可运行版本，并给出启动命令。
3. 用 curl 示例验证后端接口可用。
4. 再搭建 Flutter 端并接入真实后端数据。
5. 完成 Windows 与 Android 的运行说明。
6. 最后给出当前未完成项与下一步建议。

## 输出要求
每个阶段都按这个模板输出：
1. 本阶段完成内容
2. 新增/修改文件清单
3. 关键代码片段
4. 本地运行与验证步骤
5. 风险与后续项

## 代码质量要求
1. 保持模块边界清晰，避免把业务逻辑塞进 UI。
2. API 响应结构统一为 `code/message/data`。
3. 对网络失败、空数据、解析失败给出可见处理。
4. 不做大而全重构，优先交付可运行 MVP。

## 如果遇到信息不足
默认按 `REQUIREMENTS.md` 做合理假设并继续推进，不要停在“方案讨论”。

现在开始执行：先给我“项目目录规划 + 第一阶段具体落地文件列表”。
