# 多阶段构建 - 前端构建 + OnlyOffice 一体化镜像

# 阶段 1: 构建前端
FROM node:18-alpine AS frontend-builder

WORKDIR /app

# 复制前端文件
COPY frontend/package*.json ./
RUN npm install

COPY frontend/ ./
RUN npm run build

# 阶段 2: OnlyOffice 运行时
FROM onlyoffice/documentserver:latest

# 复制前端构建产物
COPY --from=frontend-builder /app/dist /usr/share/nginx/html

# 添加前端 Nginx 配置（监听 8050，不影响 OnlyOffice 的 80）
RUN echo 'server { \n\
    listen 8050; \n\
    server_name localhost; \n\
    root /usr/share/nginx/html; \n\
    index index.html; \n\
    location / { \n\
        try_files $uri $uri/ /index.html; \n\
    } \n\
}' > /etc/nginx/conf.d/frontend.conf

# 禁用 JWT
ENV JWT_ENABLED=false

# 暴露端口：8090=前端，80=OnlyOffice（映射到 8089）
EXPOSE 8090 80

CMD ["/app/ds/run-document-server.sh"]
