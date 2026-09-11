<template>
  <div id="app">
    <!-- 加载状态 -->
    <div v-if="loading" class="loading">
      <div class="spinner"></div>
      <p>正在加载文档...</p>
    </div>

    <!-- 编辑器 -->
    <div v-else-if="editorReady" class="editor-container">
      <div id="editor" class="editor"></div>
    </div>

    <!-- 错误提示 -->
    <div v-else-if="error" class="loading">
      <p style="color: #c00;">{{ error }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const loading = ref(true)
const editorReady = ref(false)
const error = ref('')
let docEditor = null

// 从 URL 直接加载文档（跳过后端）
async function loadDocument(url) {
  try {
    // 提取文件扩展名
    const ext = url.split('?')[0].split('.').pop().toLowerCase()

    // 文件类型映射
    const typeMap = {
      'docx': ['word', 'docx'], 'doc': ['word', 'doc'],
      'xlsx': ['cell', 'xlsx'], 'xls': ['cell', 'xls'],
      'pptx': ['slide', 'pptx'], 'ppt': ['slide', 'ppt']
    }

    if (!typeMap[ext]) {
      throw new Error(`不支持的格式: .${ext}`)
    }

    const [docType, fileType] = typeMap[ext]

    // 加载 OnlyOffice API（端口 8089）
    // 前端: http://localhost:8050
    // OnlyOffice: http://localhost:8089
    const onlyofficeUrl = `${window.location.protocol}//${window.location.hostname}:8089`
    await loadAPI(onlyofficeUrl)

    // 直接配置编辑器使用在线 URL
    const config = {
      document: {
        fileType: fileType,
        key: `doc_${Date.now()}`,
        title: `在线文档.${ext}`,
        url: url,  // ✅ 直接使用在线 URL
        permissions: {
          download: true,
          edit: true,
          print: true
        }
      },
      documentType: docType,
      editorConfig: {
        mode: "edit",
        lang: "zh-CN",
        user: {
          id: "1",
          name: "访客"
        },
        customization: {
          autosave: true
        }
      },
      type: "desktop",
      width: "100%",
      height: "100%"
    }

    initEditor(config)

  } catch (e) {
    error.value = e.message || '加载失败'
    loading.value = false
  }
}

// 加载 OnlyOffice API
function loadAPI(baseUrl) {
  return new Promise((resolve, reject) => {
    if (window.DocsAPI) {
      resolve()
      return
    }

    const script = document.createElement('script')
    script.src = `${baseUrl}/web-apps/apps/api/documents/api.js`
    script.onload = () => {
      const timer = setInterval(() => {
        if (window.DocsAPI?.DocEditor) {
          clearInterval(timer)
          resolve()
        }
      }, 100)
      setTimeout(() => {
        clearInterval(timer)
        reject(new Error('OnlyOffice API 加载超时'))
      }, 5000)
    }
    script.onerror = () => reject(new Error('无法加载 OnlyOffice API，请检查服务是否运行'))
    document.head.appendChild(script)
  })
}

// 初始化编辑器
function initEditor(config) {
  loading.value = false
  editorReady.value = true

  setTimeout(() => {
    docEditor = new window.DocsAPI.DocEditor("editor", {
      ...config,
      events: {
        onAppReady: () => console.log('✅ 编辑器就绪'),
        onError: (e) => console.error('❌ 错误:', e),
      }
    })
  }, 100)
}

// 页面加载时从 URL 参数读取
onMounted(() => {
  const url = new URLSearchParams(window.location.search).get('url')
  if (url) {
    console.log('📥 直接加载在线文档:', url)
    loadDocument(url)
  } else {
    error.value = '请提供 url 参数，例如: ?url=http://example.com/doc.xlsx'
    loading.value = false
  }
})
</script>

<style>
/* 全局清除所有间距 */
* {
  margin: 0 !important;
  padding: 0 !important;
  box-sizing: border-box;
}

html, body, #app {
  width: 100%;
  height: 100%;
  overflow: hidden;
  font-family: 'Segoe UI', Arial, sans-serif;
}

/* 加载状态 */
.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  background: #f5f5f5;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.loading p {
  margin-top: 1rem !important;
  color: #666;
}

/* 编辑器 - 100% 全屏，零间距 */
.editor-container {
  width: 100% !important;
  height: 100% !important;
  margin: 0 !important;
  padding: 0 !important;
  overflow: hidden;
}

.editor {
  width: 100% !important;
  height: 100% !important;
  margin: 0 !important;
  padding: 0 !important;
  border: none !important;
}
</style>
