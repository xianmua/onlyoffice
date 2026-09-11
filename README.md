# OnlyOffice 极简在线编辑器

一体化 Docker 镜像，包含前端编辑器 + OnlyOffice Document Server。

## 🚀 快速部署（Docker 方式）

拉取项目后，**无需手动构建前端**——Dockerfile 采用多阶段构建，`docker build` 时会自动执行 `npm install` 和 `npm run build`。

```bash
# 构建镜像（前端构建自动完成）
docker build -t onlyoffice-editor .

# 启动容器
# 8090 = 前端，8089 = OnlyOffice API
docker run -d -p 8090:8090 -p 8089:80 --name onlyoffice onlyoffice-editor
```

## 📦 离线部署（已有镜像 tar 包）

服务器上没有源码、或不方便拉取 npm 依赖时，直接导入镜像：

```bash
# 导入镜像
docker load -i onlyoffice-editor.tar.gz

# 启动（同上）
docker run -d -p 8090:8090 -p 8089:80 --name onlyoffice onlyoffice-editor
```

导出镜像命令（在本机执行）：

```bash
docker save onlyoffice-editor | gzip > onlyoffice-editor.tar.gz
```

## 💻 本地开发（不用 Docker 跑前端）

只需 Docker 跑 OnlyOffice，前端用 Vite 热更新调试：

```bash
# 1. 启动 OnlyOffice（映射到 8089）
docker run -d -p 8089:80 --name onlyoffice-dev onlyoffice/documentserver

# 2. 启动前端开发服务器（端口 8090）
cd frontend
npm install
npm run dev
```

## 📝 使用方法

```
http://localhost:8090?url=在线文档地址
```

**示例：**
```
http://localhost:8090?url=http://rsj.yulin.gov.cn/tszl/rsrc/rczp/P020260812319538702109.xlsx
```

## 📊 端口说明

| 端口 | 用途 | 说明 |
|------|------|------|
| **8090** | 前端页面 | 用户访问入口 |
| **8089** | OnlyOffice API | 内部接口（前端自动调用） |

## 📦 支持格式

- Word: `.docx`, `.doc`
- Excel: `.xlsx`, `.xls`
- PowerPoint: `.pptx`, `.ppt`

## 🔧 管理命令

```bash
# 查看日志
docker logs -f onlyoffice

# 停止
docker stop onlyoffice

# 重启
docker restart onlyoffice

# 删除
docker rm -f onlyoffice
```

## 📁 项目结构

```
onlyoffice-demo/
├── Dockerfile       # 一体化镜像定义（多阶段：前端构建 + OnlyOffice）
├── frontend/        # 前端源码（Vue3 + Vite）
└── README.md
```

## 📄 License

MIT
