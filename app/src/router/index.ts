import { createRouter, createWebHistory } from 'vue-router';
import { isFeatureEnabled } from '../featureFlags';
import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'Home',
    component: () => import('../HomePage.vue')
  }
];

// Додаємо FAQ маршрут, якщо функція увімкнена
if (isFeatureEnabled('FAQ_ENABLED')) {
  routes.push({
    path: '/faq',
    name: 'FAQ',
    component: () => import('../features/faq/FaqScreen.vue')
  });
}

const router = createRouter({
  history: createWebHistory(),
  routes
});

// Додаємо логування для діагностики
router.beforeEach((to, from, next) => {
  console.log('Router navigation:', { from: from.path, to: to.path });
  next();
});

router.afterEach((to) => {
  console.log('Router navigation completed to:', to.path);
});

export default router;
