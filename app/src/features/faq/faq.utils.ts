import type { VNode } from 'vue';
import { h } from 'vue';

/**
 * Підсвічує збіги у тексті, обгортаючи їх у <mark> теги
 * @param text - оригінальний текст
 * @param query - пошуковий запит
 * @returns масив VNode з підсвіченими збігами або оригінальний текст
 */
export function highlight(text: string, query: string): VNode[] | string {
  if (!query.trim()) {
    return text;
  }

  const lowerText = text.toLowerCase();
  const lowerQuery = query.toLowerCase();
  const index = lowerText.indexOf(lowerQuery);

  if (index === -1) {
    return text;
  }

  const before = text.substring(0, index);
  const match = text.substring(index, index + query.length);
  const after = text.substring(index + query.length);

  const result: VNode[] = [];

  if (before) {
    result.push(h('span', before));
  }

  result.push(h('mark', { class: 'faq-highlight' }, match));

  if (after) {
    // Рекурсивно обробляємо решту тексту
    const afterHighlighted = highlight(after, query);
    if (Array.isArray(afterHighlighted)) {
      result.push(...afterHighlighted);
    } else {
      result.push(h('span', afterHighlighted));
    }
  }

  return result;
}
