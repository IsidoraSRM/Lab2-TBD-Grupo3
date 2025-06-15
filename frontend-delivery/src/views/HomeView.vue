<template>
    <div class="home">
      <!-- Hero Section -->
      <section class="hero-section">
          <div class="hero-card card">
              <h1>DocDelivery</h1>
              <h2>Sistema de Gestión de Pedidos - Delivery de documentos</h2>
              <p>Gestiona y realiza seguimiento a todos tus envíos de documentos de manera eficiente y segura.</p>
          </div>
      </section>

      <!-- Carrusel de Imágenes -->
      <section class="carousel-section">
        <div class="carousel-container">
          <button class="carousel-button prev" @click="prevSlide">&lt;</button>
          
          <div class="carousel">
            <div 
              class="slide" 
              v-for="(image, index) in images" 
              :key="index"
              :class="{ active: currentSlide === index }"
            >
              <img :src="getImageUrl(image)" alt="DocDelivery service">
            </div>
          </div>
          
          <button class="carousel-button next" @click="nextSlide">&gt;</button>
          
          <div class="carousel-dots">
            <span 
              v-for="(image, index) in images" 
              :key="index"
              :class="{ active: currentSlide === index }"
              @click="goToSlide(index)"
            ></span>
          </div>
        </div>
      </section>
    </div>
  </template>
  
  <script>
  export default {
    name: 'HomeView',
    data() {
      return {
        images: ['image1.jpeg', 'image2.jpeg', 'image3.jpeg'],
        currentSlide: 0,
        interval: null
      }
    },
    methods: {
      getImageUrl(imageName) {
        return new URL(`../assets/${imageName}`, import.meta.url).href
      },
      nextSlide() {
        this.currentSlide = (this.currentSlide + 1) % this.images.length;
        this.resetInterval();
      },
      prevSlide() {
        this.currentSlide = (this.currentSlide - 1 + this.images.length) % this.images.length;
        this.resetInterval();
      },
      goToSlide(index) {
        this.currentSlide = index;
        this.resetInterval();
      },
      startInterval() {
        this.interval = setInterval(() => {
          this.nextSlide();
        }, 5000);
      },
      resetInterval() {
        clearInterval(this.interval);
        this.startInterval();
      }
    },
    mounted() {
      this.startInterval();
    },
    beforeUnmount() {
      clearInterval(this.interval);
    }
  }
  </script>

<style>
/* Hero Section */
.hero-section {
    margin-bottom: 30px;
}

.hero-card {
    text-align: center;
    background-color: #125A6C;
    color: white;
    width: 100%;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.hero-card h1 {
    font-size: 2.5rem;
    margin-bottom: 10px;
}

.hero-card h2 {
    font-size: 1.5rem;
    margin-bottom: 15px;
    font-weight: 400;
}

.hero-card p {
    font-size: 1.1rem;
    max-width: 700px;
    margin: 0 auto;
}

/* Carrusel Styles */
.carousel-section {
    margin: 30px 0;
}

.carousel-container {
    position: relative;
    max-width: 1200px;
    margin: 0 auto;
    overflow: hidden;
}

.carousel {
    display: flex;
    transition: transform 0.5s ease;
    height: 0;
    padding-bottom: 56.25%; /* 16:9 Aspect Ratio */
    position: relative;
}

.slide {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    opacity: 0;
    transition: opacity 0.5s ease;
}

.slide.active {
    opacity: 1;
}

.slide img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 8px;
}

.carousel-button {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    background-color: rgba(18, 90, 108, 0.7);
    color: white;
    border: none;
    padding: 15px;
    cursor: pointer;
    font-size: 1.5rem;
    z-index: 10;
    border-radius: 50%;
    width: 50px;
    height: 50px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background-color 0.3s;
}

.carousel-button:hover {
    background-color: #125A6C;
}

.prev {
    left: 20px;
}

.next {
    right: 20px;
}

.carousel-dots {
    position: absolute;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    gap: 10px;
}

.carousel-dots span {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background-color: rgba(255, 255, 255, 0.5);
    cursor: pointer;
    transition: background-color 0.3s;
}

.carousel-dots span.active {
    background-color: white;
}

/* Responsive */
@media (max-width: 768px) {
    .hero-card h1 {
        font-size: 2rem;
    }
    
    .hero-card h2 {
        font-size: 1.2rem;
    }
    
    .carousel-button {
        width: 40px;
        height: 40px;
        padding: 10px;
        font-size: 1.2rem;
    }
}

.home {
  background-color: var(--bg-primary);
  min-height: calc(100vh - 120px);
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.hero-section {
  background-color: var(--bg-secondary);
  padding: 3rem 2rem;
  border-radius: 8px;
  margin: 2rem auto;
  max-width: 800px;
  color: var(--text-primary);
  text-align: center;
  border: 1px solid var(--border-blue);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
}

.hero-title {
  font-size: 2.5rem;
  margin-bottom: 1rem;
  color: var(--text-primary);
  font-weight: 600;
  letter-spacing: -0.5px;
}

.hero-subtitle {
  font-size: 1.2rem;
  color: var(--text-secondary);
  max-width: 600px;
  margin: 0 auto 2rem;
  line-height: 1.6;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
  margin-top: 4rem;
  padding: 0 1rem;
}

.feature-card {
  background-color: var(--bg-secondary);
  padding: 2rem;
  border-radius: 8px;
  border: 1px solid var(--border-blue);
  transition: transform 0.3s ease;
}

.feature-card:hover {
  transform: translateY(-5px);
}

.feature-title {
  color: var(--text-primary);
  font-size: 1.25rem;
  margin-bottom: 1rem;
  font-weight: 500;
}

.feature-description {
  color: var(--text-secondary);
  line-height: 1.6;
  font-size: 0.95rem;
}

.cta-button {
  background-color: var(--bg-secondary);
  color: var(--text-primary);
  padding: 0.75rem 1.5rem;
  border: 1px solid var(--border-blue);
  border-radius: 6px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.cta-button:hover {
  background-color: var(--text-primary);
  color: var(--bg-primary);
}

@media (max-width: 768px) {
  .home {
    padding: 1rem;
  }

  .hero-section {
    padding: 2rem 1rem;
    margin: 1rem auto;
  }

  .hero-title {
    font-size: 2rem;
  }

  .hero-subtitle {
    font-size: 1rem;
  }

  .features-grid {
    grid-template-columns: 1fr;
    margin-top: 2rem;
  }
}
</style>