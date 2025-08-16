import type { FaqDocument } from './faq.types';

class FaqRepository {
  private cache = new Map<string, FaqDocument>();

  async getFaq(lang: string): Promise<FaqDocument> {
    // Перевіряємо кеш
    if (this.cache.has(lang)) {
      return this.cache.get(lang)!;
    }

    try {
      // Спробуємо завантажити файл для вказаної мови
      const response = await fetch(`/data/faq.${lang}.json`);
      if (response.ok) {
        const data = await response.json();
        this.cache.set(lang, data);
        return data;
      }
    } catch (error) {
      console.warn(`Failed to load FAQ for language: ${lang}`, error);
    }

    // Fallback на українську мову
    if (lang !== 'uk') {
      return this.getFaq('uk');
    }

    // Якщо навіть українська не завантажилася, повертаємо пустий документ
    const fallbackData: FaqDocument = {
      version: 1,
      categories: []
    };
    
    this.cache.set(lang, fallbackData);
    return fallbackData;
  }

  clearCache(): void {
    this.cache.clear();
  }
}

export const faqRepository = new FaqRepository();
