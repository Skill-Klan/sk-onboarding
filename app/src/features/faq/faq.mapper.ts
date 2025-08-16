import type { FaqDocument, FaqCategory, FaqQuestion } from './faq.types';

export class FaqMapper {
  static mapDocument(rawData: any): FaqDocument {
    // Перевіряємо базову структуру
    if (!rawData || typeof rawData !== 'object') {
      return this.getDefaultDocument();
    }

    const { version, categories } = rawData;

    // Валідуємо версію
    const validVersion = typeof version === 'number' && version > 0 ? version : 1;

    // Валідуємо категорії
    const validCategories = Array.isArray(categories) 
      ? categories.map(cat => this.mapCategory(cat)).filter(Boolean)
      : [];

    return {
      version: validVersion,
      categories: validCategories
    };
  }

  private static mapCategory(rawCategory: any): FaqCategory | null {
    if (!rawCategory || typeof rawCategory !== 'object') {
      return null;
    }

    const { id, title, items } = rawCategory;

    // Перевіряємо обов'язкові поля
    if (typeof id !== 'string' || !id.trim() || 
        typeof title !== 'string' || !title.trim()) {
      return null;
    }

    // Валідуємо питання
    const validItems = Array.isArray(items) 
      ? items.map(item => this.mapQuestion(item)).filter(Boolean)
      : [];

    return {
      id: id.trim(),
      title: title.trim(),
      items: validItems
    };
  }

  private static mapQuestion(rawQuestion: any): FaqQuestion | null {
    if (!rawQuestion || typeof rawQuestion !== 'object') {
      return null;
    }

    const { id, question, answer } = rawQuestion;

    // Перевіряємо обов'язкові поля
    if (typeof id !== 'string' || !id.trim() || 
        typeof question !== 'string' || !question.trim() ||
        typeof answer !== 'string') {
      return null;
    }

    return {
      id: id.trim(),
      question: question.trim(),
      answer: answer || ''
    };
  }

  private static getDefaultDocument(): FaqDocument {
    return {
      version: 1,
      categories: []
    };
  }
}
