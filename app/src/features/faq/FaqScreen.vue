<template>
  <div class="faq-screen">
                   <div class="faq-header">
                 <h1 class="faq-title">{{ t('faq.title') }}</h1>
                 <p class="faq-subtitle">{{ t('faq.subtitle') }}</p>
               </div>
    
                   <div class="faq-search">
                 <input
                   v-model="searchQuery"
                   type="text"
                   :placeholder="t('faq.search.placeholder')"
                   class="search-input"
                 />
               </div>
    
    <div class="faq-content">
      <!-- Стан завантаження -->
      <div v-if="loading" class="faq-loading">
        <div class="loading-spinner"></div>
        <p>{{ t('faq.loading') }}</p>
      </div>
      
      <!-- Помилка -->
      <div v-else-if="error" class="faq-error">
        <p>{{ t('faq.error.title') }}</p>
        <button @click="loadFaqData" class="retry-button">{{ t('faq.error.retry') }}</button>
      </div>
      
      <!-- Порожній стан -->
      <div v-else-if="filteredCategories.length === 0 && !loading" class="faq-empty">
        <h3>{{ t('faq.empty.title') }}</h3>
        <p>{{ t('faq.empty.description') }}</p>
      </div>
      
      <!-- Категорії FAQ -->
      <div v-else-if="filteredCategories.length > 0" class="faq-categories">
        <div 
          v-for="category in filteredCategories" 
          :key="category.id"
          class="faq-category"
        >
                      <h3 class="category-title" v-html="highlightText(category.title, searchQuery)"></h3>
          <div class="category-questions">
            <div 
              v-for="question in category.items" 
              :key="question.id"
              class="faq-question"
            >
              <button 
                @click="toggleQuestion(question.id)"
                class="question-header"
                :class="{ 'is-open': openQuestions.has(question.id) }"
              >
                <h4 class="question-title" v-html="highlightText(question.question, searchQuery)"></h4>
                <span class="question-icon">
                  {{ openQuestions.has(question.id) ? '−' : '+' }}
                </span>
              </button>
              
                                       <transition name="faq-answer">
                           <div 
                             v-if="openQuestions.has(question.id)"
                             class="question-answer-wrapper"
                           >
                             <MarkdownRenderer :content="question.answer" />
                           </div>
                         </transition>
            </div>
          </div>
        </div>
      </div>
      
                       <div class="faq-actions">
                   <button @click="goBack">{{ t('faq.actions.go_back') }}</button>
                 </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { ref, computed, watch, onMounted } from 'vue';
import MarkdownRenderer from './MarkdownRenderer.vue';
import { i18n } from 'vue-i18n';

const router = useRouter();
const { t } = useI18n();
const searchQuery = ref('');
const openQuestions = ref(new Set<string>());

// Дані FAQ
const faqData = ref([]);
const loading = ref(false);
const error = ref(null);

// Фільтрація категорій за пошуковим запитом
const filteredCategories = computed(() => {
  if (!searchQuery.value.trim()) {
    return faqData.value;
  }
  
  const query = searchQuery.value.toLowerCase();
  
  return faqData.value.map(category => {
    // Фільтруємо питання всередині категорії
    const filteredItems = category.items.filter(item =>
      item.question.toLowerCase().includes(query) ||
      item.answer.toLowerCase().includes(query)
    );
    
    // Повертаємо категорію тільки якщо є відповідні питання
    if (filteredItems.length > 0) {
      return {
        ...category,
        items: filteredItems
      };
    }
    
    // Якщо заголовок категорії співпадає, показуємо всі питання
    if (category.title.toLowerCase().includes(query)) {
      return category;
    }
    
    return null;
  }).filter(Boolean); // Видаляємо null значення
});

// Автоматично розгортаємо питання при пошуку
watch(searchQuery, (newQuery) => {
  if (newQuery.trim()) {
    const query = newQuery.toLowerCase();
    
    // Знаходимо всі питання, що співпадають
    faqData.value.forEach(category => {
      category.items.forEach(item => {
        if (item.question.toLowerCase().includes(query) ||
            item.answer.toLowerCase().includes(query)) {
          openQuestions.value.add(item.id);
        }
      });
    });
  } else {
    // Якщо пошук очищений, згортаємо всі питання
    openQuestions.value.clear();
  }
});

// Функція завантаження FAQ даних
const loadFaqData = async () => {
  loading.value = true;
  error.value = null;
  
  try {
    // Отримуємо поточну мову з i18н
    const currentLang = 'uk'; // TODO: замінити на реальну мову з i18н
    
    // Завантажуємо дані з JSON файлу
    const response = await fetch(`/sk-onboarding/data/faq.${currentLang}.json`);
    if (!response.ok) {
      throw new Error('Failed to load FAQ data');
    }
    
    const data = await response.json();
    faqData.value = data.categories || [];
    
    console.log('FAQ data loaded successfully:', faqData.value);
  } catch (err) {
    console.error('Error loading FAQ data:', err);
    error.value = 'Помилка завантаження даних';
    
    // Fallback на тестові дані
    faqData.value = [
      {
        id: 'error',
        title: t('faq.error.title'),
        items: [
          {
            id: 'fallback',
            question: t('faq.error.fallback.question'),
            answer: t('faq.error.fallback.answer')
          }
        ]
      }
    ];
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  console.log('FaqScreen mounted successfully');
  loadFaqData();
});

const goBack = () => {
  router.push('/');
};

const toggleQuestion = (questionId: string) => {
  if (openQuestions.value.has(questionId)) {
    openQuestions.value.delete(questionId);
  } else {
    openQuestions.value.add(questionId);
  }
};

// Функція для підсвічування збігів у тексті
const highlightText = (text: string, query: string): string => {
  if (!query.trim()) {
    return text;
  }
  
  const regex = new RegExp(`(${query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
  return text.replace(regex, '<mark class="search-highlight">$1</mark>');
};
</script>

<style scoped>
.faq-screen {
  min-height: 100vh;
  background: var(--tg-theme-bg-color, #ffffff);
}

.faq-header {
  text-align: center;
  padding: 32px 20px 24px;
  background: var(--tg-theme-bg-color, #ffffff);
}

.faq-title {
  font-size: 28px;
  font-weight: 700;
  color: var(--tg-theme-text-color, #000000);
  margin: 0 0 12px 0;
  line-height: 1.2;
}

.faq-subtitle {
  font-size: 16px;
  color: var(--tg-theme-hint-color, #666666);
  margin: 0;
  line-height: 1.4;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.faq-search {
  padding: 20px;
  text-align: center;
}

.search-input {
  width: 100%;
  max-width: 400px;
  padding: 12px 16px;
  border: 2px solid var(--tg-theme-hint-color, #e0e0e0);
  border-radius: 8px;
  font-size: 16px;
  outline: none;
  transition: border-color 0.2s ease;
}

.search-input:focus {
  border-color: var(--tg-theme-button-color, #0088cc);
}

.faq-content {
  text-align: center;
  padding: 40px 20px;
}

.faq-content p {
  font-size: 18px;
  margin-bottom: 20px;
  color: var(--tg-theme-text-color, #000000);
}

.faq-content button {
  background: var(--tg-theme-button-color, #0088cc);
  color: var(--tg-theme-button-text-color, #ffffff);
  border: none;
  border-radius: 8px;
  padding: 12px 24px;
  font-size: 16px;
  cursor: pointer;
}

.faq-categories {
  max-width: 800px;
  margin: 0 auto;
}

.faq-category {
  margin-bottom: 30px;
  padding: 20px;
  border: 1px solid var(--tg-theme-hint-color, #e0e0e0);
  border-radius: 12px;
  background: var(--tg-theme-bg-color, #ffffff);
}

.category-title {
  font-size: 20px;
  font-weight: 600;
  color: var(--tg-theme-text-color, #000000);
  margin: 0 0 20px 0;
  padding-bottom: 10px;
  border-bottom: 2px solid var(--tg-theme-button-color, #0088cc);
}

.category-questions {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.faq-question {
  border: 1px solid var(--tg-theme-hint-color, #e0e0e0);
  border-radius: 8px;
  overflow: hidden;
}

.question-header {
  width: 100%;
  background: var(--tg-theme-secondary-bg-color, #f8f8f8);
  border: none;
  padding: 15px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: space-between;
  text-align: left;
  transition: background-color 0.2s ease;
}

.question-header:hover {
  background: var(--tg-theme-hint-color, #e0e0e0);
}

.question-header.is-open {
  background: var(--tg-theme-button-color, #0088cc);
  color: var(--tg-theme-button-text-color, #ffffff);
}

.question-title {
  font-size: 16px;
  font-weight: 500;
  margin: 0;
  flex: 1;
}

.question-icon {
  font-size: 20px;
  font-weight: bold;
  margin-left: 15px;
}

.question-title {
  font-size: 16px;
  font-weight: 500;
  color: var(--tg-theme-text-color, #000000);
  margin: 0 0 10px 0;
}

.question-answer-wrapper {
  padding: 15px;
  background: var(--tg-theme-bg-color, #ffffff);
}

.question-answer {
  font-size: 14px;
  color: var(--tg-theme-hint-color, #666666);
  margin: 0;
  line-height: 1.5;
}

/* Анімації для акордеону */
.faq-answer-enter-active,
.faq-answer-leave-active {
  transition: all 0.3s ease;
  overflow: hidden;
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

/* Стилі для підсвічування збігів у пошуку */
.search-highlight {
  background: var(--tg-theme-button-color, #0088cc);
  color: var(--tg-theme-button-text-color, #ffffff);
  padding: 2px 4px;
  border-radius: 4px;
  font-weight: 600;
  animation: highlightPulse 0.6s ease-out;
}

@keyframes highlightPulse {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
  }
}

.faq-actions {
  text-align: center;
  margin-top: 30px;
}

/* Стилі для завантаження та помилок */
.faq-loading,
.faq-error {
  text-align: center;
  padding: 60px 20px;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--tg-theme-hint-color, #e0e0e0);
  border-top: 3px solid var(--tg-theme-button-color, #0088cc);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.faq-loading p,
.faq-error p {
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
  cursor: pointer;
  margin-top: 16px;
}

/* Стилі для порожнього стану */
.faq-empty {
  text-align: center;
  padding: 60px 20px;
}

.faq-empty h3 {
  color: var(--tg-theme-text-color, #000000);
  font-size: 18px;
  margin: 0 0 12px 0;
}

.faq-empty p {
  color: var(--tg-theme-hint-color, #666666);
  font-size: 16px;
  margin: 0;
}

@media (max-width: 480px) {
  .faq-header {
    padding: 24px 16px 20px;
  }
  
  .faq-title {
    font-size: 24px;
  }
  
  .faq-subtitle {
    font-size: 14px;
  }
}

@media (min-width: 768px) {
  .faq-header {
    padding: 40px 24px 32px;
  }
  
  .faq-title {
    font-size: 32px;
  }
  
  .faq-subtitle {
    font-size: 18px;
  }
}

@media (min-width: 1280px) {
  .faq-header {
    max-width: 960px;
    margin: 0 auto;
  }
}
</style>
