# 网站 A 内嵌集成指南

外部业务系统把编辑器内嵌到自己的页面，并在用户点「提交」时拿回改好的文档。

## 核心概念

- **f（文件 id）**：文档在本服务的唯一标识，内嵌地址 `/?f=<id>`、导出 `/api/export?f=` 都靠它。**f 是集成方唯一的句柄，务必第一时间拿到并保存**
- **托管文档**：通过导入/上传落到本服务的文件，才有保存回调、协同、导出等全部能力
- **保存回调**：Document Server 在自动保存 / Ctrl+S / 关闭编辑器时，自动把最新文档 POST 到本服务 `/api/callback?f=<id>` 覆盖原文件。**这一步全自动，集成方无需参与**

## 两种内嵌方式

| | 方式一：A 先导入（推荐） | 方式二：`?url=` 直接连 |
|---|---|---|
| 流程 | A 调 `/api/import` 拿 `id`，再用 `/?f=<id>` 内嵌 | 直接内嵌 `/?url=<文档直链>` |
| f 归属 | **A 主动拿到**，记入自己的库 | 页面内部自动转托管生成新 f，**A 拿不到**（iframe 跨域读不到子页地址栏） |
| 幂等 | 同一业务文档永远同一个 f | 每次可能生成新 f，协同分裂 |
| 提交拿文档 | 直接 `/api/export?f=` | 需另加 postMessage 桥通知 f（目前未实现） |

**结论：集成一律走方式一。** `?url=` 只适合临时预览场景。

## 推荐集成流程

```text
① A 后端调 POST /api/import {url} → 得 { id }
② A 把「业务单据 ↔ f」映射存入自己的数据库
③ A 页面内嵌 <iframe src="http://服务:8090/?f=<id>">
④ 用户编辑（改动由 DS 自动保存落盘，无需干预）
⑤ 用户点 A 的「提交」按钮：
   A 后端 GET /api/export?f=<id>&format=docx
   → 服务内部先 forcesave 拉最新版再返回文件流
   → A 存入自己的服务器/数据库
```

## 关键代码

**第 ① 步：导入并记住 f**

```js
const r = await fetch('http://<服务主机>:8090/api/import', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ url: 'https://源站/报告.docx' }),
})
const { id, name } = await r.json()
// 存映射：biz_doc_id ↔ id（f）
```

**第 ③ 步：内嵌**

```html
<iframe src="http://<服务主机>:8090/?f=<id>"
        style="width:100%;height:100%;border:none"></iframe>
```

**第 ⑤ 步：提交时回传**

```js
const r = await fetch(`http://<服务主机>:8090/api/export?f=${f}&format=docx`)
const buf = Buffer.from(await r.arrayBuffer())   // 用户改好的最新文档
// 写入 A 自己的存储
```

CORS 已全开放，A 的前端直接调也行；走 A 的后端更稳妥（便于加鉴权与审计）。

## 注意事项

- **接口无鉴权**（见 API.md），仅限内网/受信网络；对外暴露须加网关
- `format` 可省略 = 原格式；要 PDF 传 `format=pdf`（forcesave 后再转格式，最多等 8 秒）
- 同一 f 多人打开即实时协同（key 绑定 f），A 无需额外处理
- 重复 import 同一 URL 会生成新 f，A 侧应先查映射避免重复导入
- 编辑器身份（用户名）由本服务企微登录/访客机制决定，与 A 的用户体系目前不打通

## 存储清理

托管文档不会无限堆积，三种机制配合：

| 机制 | 触发方式 | 适用场景 |
|---|---|---|
| **webhook 直通**（免清理） | import 时传 `webhook` 参数，保存回调把文档直接 POST 给 A，默认转发成功即删本地副本 | 提交即回传，服务端零残留 |
| **显式删除**（推荐） | A 提交回传后调 `DELETE /api/doc?f=<id>` | 普通流程：文档用完即删，立即释放 |
| **TTL 自动清理**（兜底） | 默认 7 天无保存动作自动删（`DOC_TTL_HOURS` 环境变量可调） | 用户导入了但一直没提交的遗留文件 |

推荐的第 ⑤ 步加上删除：

```js
// 提交回传成功后顺手清理服务端文件
await fetch(`http://<服务主机>:8090/api/doc?f=${f}`, { method: 'DELETE' })
```

> TTL 按「最后一次保存时间」计算（每次编辑保存会自动续期）；若 A 的业务文档需要超过 7 天后才提交，要么调大 `DOC_TTL_HOURS`，要么期间保持有编辑动作。
