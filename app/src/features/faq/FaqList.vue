<template>
  <div class="faq-list">
            <div v-if="loading" class="faq-loading">
          <div class="loading-spinner"></div>
          <p>{{ t('faq.loading') }}</p>
        </div>
        
        <div v-else-if="error" class="faq-error">
          <p>{{ t('faq.error') }}</p>
          <button @click="retryLoad" class="retry-button">
            {{ t('faq.retry') }}
          </button>
        </div>
        
        <div v-else-if="filteredCategories.length === 0" class="faq-empty">
          <div v-if="searchQuery" class="faq-no-results">
            <p>{{ t('faq.noResults') }}</p>
            <p class="search-query">"{{ searchQuery }}"</p>
          </div>
          <div v-else class="faq-no-categories">
            <p>{{ t('faq.noCategories') }}</p>
          </div>
        </div>
    
    <div v-else class="faq-categories">
      <faq-category-item
        v-for="category in filteredCategories"
        :key="category.id"
        :category="category"
        :search-query="searchQuery"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { FaqCategoryItem } from './FaqCategoryItem.vue';
import { faqRepository } from './faq.repository';
import { FaqMapper } from './faq.mapper';
import type { FaqDocument, FaqCategory } from './faq.types';
import { useI18n } from 'vue-i18n';
import { computed, ref, watch, onMounted } from 'vue';

interface FaqListProps {
  searchQuery: string;
}

const props = defineProps<FaqListProps>();
const i18n = useI18n();

const loading = ref(false);
const error = ref<string | null>(null);
const faqData = ref<FaqDocument | null>(null);

const filteredCategories = computed(() => {
  if (!faqData.value) return [];
  
  if (!props.searchQuery.trim()) {
    return faqData.value.categories;
  }
  
  const query = props.searchQuery.toLowerCase();
  
  return faqData.value.categories.filter(category => {
    // Перевіряємо, чи збігається заголовок категорії
    if (category.title.toLowerCase().includes(query)) {
      return true;
    }
    
    // Перевіряємо, чи є питання, що збігаються
    const hasMatchingQuestions = category.items.some(item =>
      item.question.toLowerCase().includes(query) ||
      item.answer.toLowerCase().includes(query)
    );
    
    return hasMatchingQuestions;
  });
});

const loadFaq = async () => {
  loading.value = true;
  error.value = null;
  
  try {
    const currentLang = i18n.locale.value;
    const rawData = await faqRepository.getFaq(currentLang);
    faqData.value = FaqMapper.mapDocument(rawData);
  } catch (err) {
    console.error('Failed to load FAQ:', err);
    error.value = 'Failed to load FAQ data';
  } finally {
    loading.value = false;
  }
};

const retryLoad = () => {
  loadFaq();
};

// Завантажуємо дані при зміні мови
watch(() => i18n.locale.value, () => {
  loadFaq();
});

onMounted(() => {
  loadFaq();
});
</script>

<style scoped>
.faq-list {
  min-height: 200px;
}

.faq-loading,
.faq-error,
.faq-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--tg-theme-hint-color, #e0e0e0);
  border-top: 3px solid var(--tg-theme-button-color, #0088cc);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.faq-loading p,
.faq-error p,
.faq-empty p {
  color: var(--tg-theme-hint-color, #666666);
  font-size: 16px;
  margin: 0;
}

.retry-button {
  background: var(--tg-theme-button-color, #0088cc);
  color: var(--tg-theme-button-text-color, #ffffff);
  border: none;
  border-radius: 8px;
  padding: 12px 24px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  margin-top: 16px;
  transition: opacity 0.2s ease;
}

.retry-button:hover {
  opacity: 0.8;
}

.faq-no-results .search-query {
  font-weight: 600;
  color: var(--tg-theme-text-color, #000000);
  margin-top: 8px;
}

.faq-categories {
  padding: 0 16px 20px;
}

@media (max-width: 480px) {
  .faq-loading,
  .faq-error,
  .faq-empty {
    padding: 40px 16px;
  }
  
  .faq-categories {
    padding: 0 12px 16px;
  }
}

@media (min-width: 768px) {
  .faq-categories {
    padding: 0 24px 32px;
  }
}

@media (min-width: 1280px) {
  .faq-categories {
    max-width: 960px;
    margin: 0 auto;
  }
}
</style>
