<template>
  <div class="markdown-content" v-html="renderedContent"></div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

interface Props {
  content: string;
}

const props = defineProps<Props>();

// Простий Markdown рендерер
const renderedContent = computed(() => {
  let content = props.content;
  
  // Заголовки
  content = content.replace(/^### (.*$)/gim, '<h3>$1</h3>');
  content = content.replace(/^## (.*$)/gim, '<h2>$1</h2>');
  content = content.replace(/^# (.*$)/gim, '<h1>$1</h1>');
  
  // Жирний текст
  content = content.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
  
  // Курсив
  content = content.replace(/\*(.*?)\*/g, '<em>$1</em>');
  
  // Код
  content = content.replace(/`(.*?)`/g, '<code>$1</code>');
  
  // Блок коду
  content = content.replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>');
  
  // Посилання
  content = content.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>');
  
  // Списки
  content = content.replace(/^\* (.*$)/gim, '<li>$1</li>');
  content = content.replace(/^- (.*$)/gim, '<li>$1</li>');
  content = content.replace(/^\d+\. (.*$)/gim, '<li>$1</li>');
  
  // Обгортання списків
  content = content.replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>');
  
  // Параграфи
  content = content.replace(/\n\n/g, '</p><p>');
  content = content.replace(/^(?!<[h|u|p|pre]).*$/gm, '<p>$&</p>');
  
  // Очищення порожніх параграфів
  content = content.replace(/<p><\/p>/g, '');
  content = content.replace(/<p>(<[h|u|p|pre])/g, '$1');
  content = content.replace(/(<\/[h|u|p|pre]>)<\/p>/g, '$1');
  
  return content;
});
</script>

<style scoped>
.markdown-content {
  line-height: 1.6;
}

.markdown-content :deep(h1) {
  font-size: 20px;
  font-weight: 600;
  margin: 16px 0 8px 0;
  color: var(--tg-theme-text-color, #000000);
}

.markdown-content :deep(h2) {
  font-size: 18px;
  font-weight: 600;
  margin: 14px 0 6px 0;
  color: var(--tg-theme-text-color, #000000);
}

.markdown-content :deep(h3) {
  font-size: 16px;
  font-weight: 600;
  margin: 12px 0 4px 0;
  color: var(--tg-theme-text-color, #000000);
}

.markdown-content :deep(p) {
  margin: 8px 0;
  color: var(--tg-theme-hint-color, #666666);
}

.markdown-content :deep(strong) {
  font-weight: 600;
  color: var(--tg-theme-text-color, #000000);
}

.markdown-content :deep(em) {
  font-style: italic;
}

.markdown-content :deep(code) {
  background: var(--tg-theme-secondary-bg-color, #f0f0f0);
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 14px;
  color: var(--tg-theme-text-color, #000000);
}

.markdown-content :deep(pre) {
  background: var(--tg-theme-secondary-bg-color, #f0f0f0);
  padding: 12px;
  border-radius: 8px;
  overflow-x: auto;
  margin: 12px 0;
}

.markdown-content :deep(pre code) {
  background: none;
  padding: 0;
  color: var(--tg-theme-text-color, #000000);
}

.markdown-content :deep(ul) {
  margin: 8px 0;
  padding-left: 20px;
}

.markdown-content :deep(li) {
  margin: 4px 0;
  color: var(--tg-theme-hint-color, #666666);
}

.markdown-content :deep(a) {
  color: var(--tg-theme-link-color, #0088cc);
  text-decoration: none;
}

.markdown-content :deep(a:hover) {
  text-decoration: underline;
}
</style>
