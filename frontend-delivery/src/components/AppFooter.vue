<script>
export default {
    name: 'AppFooter',
};
</script>

<template>
    <footer class="footer">
        <div class="footer-left">
            <span class="footer-text">© 2025 DocDelivery. Grupo 3 TBD.</span>
        </div>
        <div class="footer-center">
            <a href="#" class="footer-link">Políticas de Privacidad</a>
            <a href="#" class="footer-link">Términos de Servicio</a>
            <a href="#" class="footer-link">Contáctanos</a>
        </div>
        <div class="footer-right">
            <a href="#" class="footer-icon" aria-label="Instagram">
                <i class="fab fa-instagram"></i>
            </a>
        </div>
    </footer>
</template>

<style scoped>
.footer {
    background-color: var(--bg-secondary);
    color: var(--text-primary);
    padding: 1.5rem 0;
    width: 100%;
    position: relative;
    bottom: 0;
    margin-top: 4rem;
    min-height: 60px;
    z-index: 10;
}

.footer-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
    flex-wrap: wrap;
    gap: 1rem;
}

.footer-links {
    display: flex;
    gap: 2rem;
    flex-wrap: wrap;
}

.footer-links a {
    color: var(--text-secondary);
    text-decoration: none;
    font-size: 0.9rem;
    transition: color 0.2s ease;
    white-space: nowrap;
}

.footer-links a:hover {
    color: var(--blue-neon);
}

.footer-bottom {
    text-align: center;
    padding-top: 1rem;
    margin-top: 1rem;
    border-top: 1px solid var(--border-blue);
    color: var(--text-secondary);
    font-size: 0.8rem;
}

.footer-left,
.footer-center,
.footer-right {
    display: flex;
    align-items: center;
}

.footer-text {
    font-weight: 400;
}

.footer-center {
    gap: 15px;
}

.footer-link {
    color: #E2DCD2;
    text-decoration: none;
    font-size: 12px;
    padding: 2px 6px;
    border-radius: 4px;
    transition: background-color 0.2s ease, color 0.2s ease;
}

.footer-link:hover {
    background-color: #F5C448;
    color: #125A6C;
}

.footer-icon {
    color: #E2DCD2;
    font-size: 14px;
    width: 24px;
    height: 24px;
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 50%;
    background-color: rgba(255, 255, 255, 0.1);
    transition: background-color 0.2s ease, transform 0.2s ease;
}

.footer-icon:hover {
    background-color: #F5C448;
    color: #125A6C;
    transform: scale(1.1);
}

@media (max-width: 768px) {
    .footer-content {
        flex-direction: column;
        text-align: center;
        gap: 1.5rem;
    }

    .footer-links {
        justify-content: center;
    }
}
</style>
