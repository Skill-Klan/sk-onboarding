import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import { createI18n } from 'vue-i18n';
import { uk, en } from './locales';

const i18n = createI18n({
  legacy: false,
  locale: 'uk',
  fallbackLocale: 'uk',
  messages: {
    uk,
    en
  }
});

const app = createApp(App);

app.use(router);
app.use(i18n);

app.mount('#app');
