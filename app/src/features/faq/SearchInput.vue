<template>
  <div class="faq-search">
    <div class="search-wrapper">
      <svg-icon name="search" class="search-icon" />
      <input
        ref="searchInput"
        v-model="searchValue"
        type="text"
        class="search-input"
        :placeholder="placeholder"
        @input="onInput"
        @focus="onFocus"
        @blur="onBlur"
      />
      <button
        v-if="searchValue"
        type="button"
        class="clear-button"
        @click="clearSearch"
      >
        <svg-icon name="close" />
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { SvgIcon } from '@tok/ui/components/SvgIcon';
import { useI18n } from 'vue-i18n';
import { computed, ref, watch } from 'vue';

interface SearchInputProps {
  modelValue: string;
  placeholder?: string;
  debounceMs?: number;
}

interface SearchInputEmits {
  (e: 'update:modelValue', value: string): void;
  (e: 'search', value: string): void;
}

const props = withDefaults(defineProps<SearchInputProps>(), {
  placeholder: '',
  debounceMs: 300
});

const emit = defineEmits<SearchInputEmits>();

const { t } = useI18n();
const searchInput = ref<HTMLInputElement | null>(null);
const searchValue = ref(props.modelValue);
const debounceTimer = ref<number | null>(null);

const translatedPlaceholder = computed(() => props.placeholder || t('faq.search.placeholder'));

watch(() => props.modelValue, (newValue) => {
  if (newValue !== searchValue.value) {
    searchValue.value = newValue;
  }
});

const onInput = () => {
  // Очищаємо попередній таймер
  if (debounceTimer.value) {
    clearTimeout(debounceTimer.value);
  }

  // Встановлюємо новий таймер
  debounceTimer.value = window.setTimeout(() => {
    emit('update:modelValue', searchValue.value);
    emit('search', searchValue.value);
  }, props.debounceMs);
};

const onFocus = () => {
  // Розширюємо WebView при фокусі на пошук
  if (window.Telegram?.WebApp) {
    window.Telegram.WebApp.expand();
  }
};

const onBlur = () => {
  // Згортаємо WebView при втраті фокусу
  if (window.Telegram?.WebApp) {
    window.Telegram.WebApp.close();
  }
};

const clearSearch = () => {
  searchValue.value = '';
  emit('update:modelValue', '');
  emit('search', '');
  searchInput.value?.focus();
};

// Очищаємо таймер при знищенні компонента
import { onBeforeUnmount } from 'vue';
onBeforeUnmount(() => {
  if (debounceTimer.value) {
    clearTimeout(debounceTimer.value);
  }
});
</script>

<style scoped>
.faq-search {
  position: sticky;
  top: 0;
  z-index: 10;
  background: var(--tg-theme-bg-color, #ffffff);
  border-bottom: 1px solid var(--tg-theme-hint-color, #e0e0e0);
  padding: 16px;
}

.search-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  background: var(--tg-theme-secondary-bg-color, #f5f5f5);
  border-radius: 12px;
  padding: 0 16px;
  min-height: 48px;
}

.search-icon {
  width: 20px;
  height: 20px;
  color: var(--tg-theme-hint-color, #999999);
  margin-right: 12px;
  flex-shrink: 0;
}

.search-input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 16px;
  color: var(--tg-theme-text-color, #000000);
  outline: none;
  min-height: 48px;
}

.search-input::placeholder {
  color: var(--tg-theme-hint-color, #999999);
}

.clear-button {
  background: none;
  border: none;
  padding: 8px;
  cursor: pointer;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--tg-theme-hint-color, #999999);
  transition: background-color 0.2s ease;
}

.clear-button:hover {
  background: var(--tg-theme-hint-color, #e0e0e0);
}

.clear-button svg {
  width: 16px;
  height: 16px;
}

@media (max-width: 480px) {
  .faq-search {
    padding: 12px;
  }
  
  .search-wrapper {
    min-height: 44px;
  }
  
  .search-input {
    min-height: 44px;
    font-size: 14px;
  }
}
</style>
