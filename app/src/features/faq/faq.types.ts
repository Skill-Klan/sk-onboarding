export type FaqQuestion = {
  id: string;
  question: string;
  answer: string; // підтримка Markdown через <MarkdownRenderer/>
};

export type FaqCategory = {
  id: string;
  title: string;
  items: FaqQuestion[];
};

export type FaqDocument = {
  version: number;
  categories: FaqCategory[];
};
