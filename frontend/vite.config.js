import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  base: '/',
  build: {
    outDir: 'dist',
    assetsDir: 'assets'
  },
  server: {
    port: 8090,
    fs: {
      strict: false
    },
    proxy: {
      // 开发环境代理 OnlyOffice API
      '/web-apps': {
        target: 'http://localhost:8089',
        changeOrigin: true,
        ws: true
      }
    },
    historyApiFallback: true
  }
})
