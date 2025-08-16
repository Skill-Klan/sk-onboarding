<template>
  <div class="home-page">
    <div class="hero-section">
              <h1 class="hero-title">Telegram Onboarding Kit</h1>
      <p class="hero-subtitle">
        Створюйте вражаючі онбординги та paywall для вашого Telegram Bot
      </p>
      
      <div class="hero-buttons">
        <button class="primary-button" @click="startOnboarding">
          Почати онбординг
        </button>
        <button class="secondary-button" @click="goToFaq">
          FAQ
        </button>
      </div>
    </div>
    
    <div class="features-section">
      <h2 class="section-title">Основні можливості</h2>
      <div class="features-grid">
        <div class="feature-card">
          <div class="feature-icon">🚀</div>
          <h3>Швидко</h3>
          <p>Створюйте онбординги за хвилини</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">🎨</div>
          <h3>Красиво</h3>
          <p>Сучасний дизайн та анімації</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">⚡</div>
          <h3>Ефективно</h3>
          <p>Підвищуйте конверсію користувачів</p>
        </div>
      </div>
    </div>
    
    <div class="cta-section">
      <h2>Готові почати?</h2>
      <p>Приєднуйтесь до тисячі успішних ботів</p>
      <button class="cta-button" @click="startOnboarding">
        Створити бота
      </button>
    </div>
    
    <!-- Нижній блок з FAQ -->
    <div class="faq-section">
      <div class="faq-content">
        <div class="faq-text">
          <h3>Маєте питання?</h3>
          <p>Знайдіть відповіді на найпопулярніші питання в нашому FAQ</p>
        </div>
        <button class="faq-button" @click="goToFaq">
          <span class="faq-icon">❓</span>
          Переглянути FAQ
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router';

const router = useRouter();

const startOnboarding = () => {
  // Логіка для початку онбордингу
  console.log('Starting onboarding...');
};

const goToFaq = async () => {
  console.log('FAQ button clicked, navigating to /faq');
  try {
    await router.push('/faq');
    console.log('Navigation completed successfully');
  } catch (error) {
    console.error('Navigation failed:', error);
  }
};
</script>

<style scoped>
.home-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.hero-section {
  text-align: center;
  padding: 80px 20px;
  max-width: 800px;
  margin: 0 auto;
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 700;
  margin-bottom: 20px;
  text-shadow: 0 2px 4px rgba(0,0,0,0.3);
}

.hero-subtitle {
  font-size: 1.25rem;
  margin-bottom: 40px;
  opacity: 0.9;
  line-height: 1.6;
}

.hero-buttons {
  display: flex;
  gap: 20px;
  justify-content: center;
  flex-wrap: wrap;
}

.primary-button,
.secondary-button {
  padding: 16px 32px;
  border: none;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 160px;
}

.primary-button {
  background: #ffffff;
  color: #667eea;
}

.primary-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.2);
}

.secondary-button {
  background: transparent;
  color: white;
  border: 2px solid white;
}

.secondary-button:hover {
  background: white;
  color: #667eea;
  transform: translateY(-2px);
}

.features-section {
  padding: 80px 20px;
  background: rgba(255,255,255,0.1);
  backdrop-filter: blur(10px);
}

.section-title {
  text-align: center;
  font-size: 2.5rem;
  margin-bottom: 60px;
  font-weight: 600;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 40px;
  max-width: 1000px;
  margin: 0 auto;
}

.feature-card {
  text-align: center;
  padding: 40px 20px;
  background: rgba(255,255,255,0.1);
  border-radius: 20px;
  backdrop-filter: blur(10px);
  transition: transform 0.3s ease;
}

.feature-card:hover {
  transform: translateY(-5px);
}

.feature-icon {
  font-size: 3rem;
  margin-bottom: 20px;
}

.feature-card h3 {
  font-size: 1.5rem;
  margin-bottom: 15px;
  font-weight: 600;
}

.feature-card p {
  opacity: 0.9;
  line-height: 1.6;
}

.cta-section {
  text-align: center;
  padding: 80px 20px;
}

.cta-section h2 {
  font-size: 2.5rem;
  margin-bottom: 20px;
  font-weight: 600;
}

.cta-section p {
  font-size: 1.25rem;
  margin-bottom: 40px;
  opacity: 0.9;
}

.cta-button {
  padding: 18px 40px;
  background: #ffffff;
  color: #667eea;
  border: none;
  border-radius: 12px;
  font-size: 1.2rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.cta-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.2);
}

/* Стилі для FAQ секції */
.faq-section {
  padding: 60px 20px;
  background: rgba(255,255,255,0.05);
  backdrop-filter: blur(10px);
}

.faq-content {
  max-width: 800px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 40px;
  flex-wrap: wrap;
}

.faq-text h3 {
  font-size: 1.8rem;
  margin-bottom: 12px;
  font-weight: 600;
}

.faq-text p {
  font-size: 1.1rem;
  opacity: 0.9;
  line-height: 1.6;
  margin: 0;
}

.faq-button {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 28px;
  background: rgba(255,255,255,0.15);
  color: white;
  border: 2px solid rgba(255,255,255,0.3);
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.faq-button:hover {
  background: rgba(255,255,255,0.25);
  border-color: rgba(255,255,255,0.5);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.2);
}

.faq-icon {
  font-size: 1.2rem;
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 2.5rem;
  }
  
  .hero-buttons {
    flex-direction: column;
    align-items: center;
  }
  
  .features-grid {
    grid-template-columns: 1fr;
    gap: 30px;
  }
  
  .section-title {
    font-size: 2rem;
  }
  
  .faq-content {
    flex-direction: column;
    text-align: center;
    gap: 30px;
  }
  
  .faq-text h3 {
    font-size: 1.6rem;
  }
}

@media (max-width: 480px) {
  .hero-section {
    padding: 60px 16px;
  }
  
  .hero-title {
    font-size: 2rem;
  }
  
  .hero-subtitle {
    font-size: 1.1rem;
  }
  
  .features-section,
  .cta-section,
  .faq-section {
    padding: 60px 16px;
  }
  
  .faq-text h3 {
    font-size: 1.4rem;
  }
  
  .faq-text p {
    font-size: 1rem;
  }
  
  .faq-button {
    padding: 14px 24px;
    font-size: 1rem;
  }
}
</style>
