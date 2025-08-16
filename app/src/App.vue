<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script setup lang="ts">
import './styles.scss';
import './features/faq/faq.animations.css';
import { useRouter } from 'vue-router';
import { onMounted } from 'vue';

const router = useRouter();

onMounted(() => {
  // Логіка ініціалізації, якщо потрібна
  console.log('App mounted');
});
</script>

<style>
#app {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>
