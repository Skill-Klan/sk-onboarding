// app/vite.config.js
import vue from '@vitejs/plugin-vue';
import { defineConfig } from 'vite';
import svgLoader from 'vite-svg-loader';
import { telegramStickerLoader } from './_internal/tgs.loader';

export default defineConfig({
  // Для локального тестування використовуємо кореневий шлях
  base: '/',
  // Якщо це репозиторна Pages:
  // !!! заміни <repo-name> на точну назву репозиторію і залиш завершаючий слеш
  // base: '/<repo-name>/',
  // Якщо це user/org pages або custom domain — заміни на '/'
  // base: '/',

  plugins: [
    telegramStickerLoader(),
    vue(),
    svgLoader({
      defaultImport: 'component',
      svgoConfig: {
        plugins: [
          {
            name: 'cleanupIds',
            params: { remove: false, minify: false },
          },
        ],
      },
    }),
  ],
  build: {
    outDir: 'dist',        // залиш dist
    assetsInlineLimit: 0,
    minify: true,
  },
});