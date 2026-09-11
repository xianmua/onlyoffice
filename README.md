# OnlyOffice 极简在线编辑器

一体化 Docker 镜像，包含前端编辑器 + OnlyOffice Document Server。

## 🚀 快速部署

### 1. 拉取基础镜像（首次构建）

```bash
docker pull onlyoffice/documentserver:latest
```

### 2. 构建并启动

```bash
# 构建镜像
docker build -t onlyoffice-editor .

# 启动容器
# 8050 = 前端，8089 = OnlyOffice API
docker run -d -p 8050:8050 -p 8089:80 --name onlyoffice onlyoffice-editor
```

## 📝 使用方法

```
http://localhost:8050?url=在线文档地址
```

**示例：**
```
http://localhost:8050?url=http://rsj.yulin.gov.cn/tszl/rsrc/rczp/P020260812319538702109.xlsx
```

## 📊 端口说明

| 端口 | 用途 | 说明 |
|------|------|------|
| **8050** | 前端页面 | 用户访问入口 |
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
├── Dockerfile       # 一体化镜像定义
├── frontend/        # 前端源码
└── README.md
```

## 📄 License

MIT
