<template>
  <div class="faq-question-item">
    <button
      type="button"
      class="question-header"
      :class="{ 'is-open': isOpen }"
      @click="toggleOpen"
    >
      <div class="question-content">
        <span class="question-text" v-html="highlightedQuestion"></span>
      </div>
      <svg-icon 
        name="chevron-down" 
        class="chevron-icon"
        :class="{ 'is-open': isOpen }"
      />
    </button>
    
    <transition name="faq-answer">
      <div v-if="isOpen" class="answer-content">
        <div class="answer-text" v-html="answer"></div>
      </div>
    </transition>
  </div>
</template>

<script setup lang="ts">
import { SvgIcon } from '@tok/ui/components/SvgIcon';
import { highlight } from './faq.utils';
import type { FaqQuestion } from './faq.types';
import { computed, ref } from 'vue';

interface FaqQuestionItemProps {
  question: FaqQuestion;
  searchQuery: string;
}

const props = defineProps<FaqQuestionItemProps>();
const isOpen = ref(false);

const highlightedQuestion = computed(() => {
  const highlighted = highlight(props.question.question, props.searchQuery);
  if (Array.isArray(highlighted)) {
    // Якщо це масив VNode, конвертуємо в HTML
    return props.question.question.replace(
      new RegExp(props.searchQuery, 'gi'),
      match => `<mark class="faq-highlight">${match}</mark>`
    );
  }
  return highlighted;
});

const toggleOpen = () => {
  isOpen.value = !isOpen.value;
};
</script>

<style scoped>
.faq-question-item {
  border-bottom: 1px solid var(--tg-theme-hint-color, #e0e0e0);
}

.question-header {
  width: 100%;
  background: none;
  border: none;
  padding: 16px 0;
  cursor: pointer;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  text-align: left;
  transition: all 0.2s ease;
}

.question-header:hover {
  background: var(--tg-theme-secondary-bg-color, #f5f5f5);
}

.question-content {
  flex: 1;
  margin-right: 16px;
}

.question-text {
  font-size: 16px;
  font-weight: 500;
  color: var(--tg-theme-text-color, #000000);
  line-height: 1.4;
}

.chevron-icon {
  width: 20px;
  height: 20px;
  color: var(--tg-theme-hint-color, #999999);
  transition: transform 0.2s ease;
  flex-shrink: 0;
}

.chevron-icon.is-open {
  transform: rotate(180deg);
}

.answer-content {
  padding: 0 0 16px 0;
  overflow: hidden;
}

.answer-text {
  font-size: 14px;
  line-height: 1.6;
  color: var(--tg-theme-hint-color, #666666);
  padding-left: 16px;
  border-left: 2px solid var(--tg-theme-hint-color, #e0e0e0);
}

/* Анімації */
.faq-answer-enter-active,
.faq-answer-leave-active {
  transition: all 0.3s ease;
}

.faq-answer-enter-from,
.faq-answer-leave-to {
  opacity: 0;
  max-height: 0;
}

.faq-answer-enter-to,
.faq-answer-leave-from {
  opacity: 1;
  max-height: 200px;
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
  .question-header {
    padding: 12px 0;
  }
  
  .question-text {
    font-size: 14px;
  }
  
  .answer-text {
    font-size: 13px;
    padding-left: 12px;
  }
}
</style>
