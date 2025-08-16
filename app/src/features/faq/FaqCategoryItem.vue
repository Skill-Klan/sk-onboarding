<template>
  <div class="faq-category-item">
    <button
      type="button"
      class="category-header"
      :class="{ 'is-open': isOpen }"
      @click="toggleOpen"
    >
      <div class="category-content">
        <span class="category-title" v-html="highlightedTitle"></span>
        <span class="category-count">({{ visibleQuestionsCount }})</span>
      </div>
      <svg-icon 
        name="chevron-down" 
        class="chevron-icon"
        :class="{ 'is-open': isOpen }"
      />
    </button>
    
    <transition name="faq-category">
      <div v-if="isOpen" class="category-content-wrapper">
        <div class="questions-list">
          <faq-question-item
            v-for="question in visibleQuestions"
            :key="question.id"
            :question="question"
            :search-query="searchQuery"
          />
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup lang="ts">
import { SvgIcon } from '@tok/ui/components/SvgIcon';
import { FaqQuestionItem } from './FaqQuestionItem.vue';
import { highlight } from './faq.utils';
import type { FaqCategory, FaqQuestion } from './faq.types';
import { computed, ref } from 'vue';

interface FaqCategoryItemProps {
  category: FaqCategory;
  searchQuery: string;
}

const props = defineProps<FaqCategoryItemProps>();
const isOpen = ref(false);

const highlightedTitle = computed(() => {
  const highlighted = highlight(props.category.title, props.searchQuery);
  if (Array.isArray(highlighted)) {
    // Якщо це масив VNode, конвертуємо в HTML
    return props.category.title.replace(
      new RegExp(props.searchQuery, 'gi'),
      match => `<mark class="faq-highlight">${match}</mark>`
    );
  }
  return highlighted;
});

const visibleQuestions = computed(() => {
  if (!props.searchQuery.trim()) {
    return props.category.items;
  }
  
  // Фільтруємо питання за пошуковим запитом
  return props.category.items.filter(item => 
    item.question.toLowerCase().includes(props.searchQuery.toLowerCase()) ||
    item.answer.toLowerCase().includes(props.searchQuery.toLowerCase())
  );
});

const visibleQuestionsCount = computed(() => visibleQuestions.value.length);

const toggleOpen = () => {
  isOpen.value = !isOpen.value;
};

// Автоматично відкриваємо категорію, якщо є пошуковий запит і є видимі питання
import { watch } from 'vue';
watch(() => props.searchQuery, (newQuery) => {
  if (newQuery.trim() && visibleQuestionsCount.value > 0) {
    isOpen.value = true;
  }
}, { immediate: true });
</script>

<style scoped>
.faq-category-item {
  border: 1px solid var(--tg-theme-hint-color, #e0e0e0);
  border-radius: 12px;
  margin-bottom: 16px;
  overflow: hidden;
  background: var(--tg-theme-bg-color, #ffffff);
}

.category-header {
  width: 100%;
  background: none;
  border: none;
  padding: 20px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: space-between;
  text-align: left;
  transition: all 0.2s ease;
}

.category-header:hover {
  background: var(--tg-theme-secondary-bg-color, #f5f5f5);
}

.category-content {
  flex: 1;
  margin-right: 16px;
}

.category-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--tg-theme-text-color, #000000);
  line-height: 1.3;
}

.category-count {
  font-size: 14px;
  color: var(--tg-theme-hint-color, #999999);
  margin-left: 8px;
  font-weight: 400;
}

.chevron-icon {
  width: 24px;
  height: 24px;
  color: var(--tg-theme-hint-color, #999999);
  transition: transform 0.2s ease;
  flex-shrink: 0;
}

.chevron-icon.is-open {
  transform: rotate(180deg);
}

.category-content-wrapper {
  border-top: 1px solid var(--tg-theme-hint-color, #e0e0e0);
  background: var(--tg-theme-secondary-bg-color, #f8f8f8);
}

.questions-list {
  padding: 0 20px;
}

/* Анімації */
.faq-category-enter-active,
.faq-category-leave-active {
  transition: all 0.3s ease;
}

.faq-category-enter-from,
.faq-category-leave-to {
  opacity: 0;
  max-height: 0;
}

.faq-category-enter-to,
.faq-category-leave-from {
  opacity: 1;
  max-height: 1000px;
}

/* Підсвічування збігів */
:deep(.faq-highlight) {
  background: var(--tg-theme-button-color, #0088cc);
  color: var(--tg-theme-button-text-color, #ffffff);
  padding: 2px 4px;
  border-radius: 4px;
  font-weight: 600;
}

@media (max-width: 480px) {
  .category-header {
    padding: 16px;
  }
  
  .category-title {
    font-size: 16px;
  }
  
  .questions-list {
    padding: 0 16px;
  }
}

@media (min-width: 768px) {
  .faq-category-item {
    margin-bottom: 20px;
  }
  
  .category-header {
    padding: 24px;
  }
  
  .category-title {
    font-size: 20px;
  }
}
</style>
