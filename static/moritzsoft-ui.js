// MoritzSoft Search — Full UI Injection
// Particles + Custom Navigation + Footer + Logo
// 1:1 moritzsoft.de Design
(function() {
    'use strict';

    // ─── PARTICLE CANVAS ─────────────────────────────
    const canvas = document.createElement('canvas');
    canvas.id = 'ms-canvas';
    document.body.insertBefore(canvas, document.body.firstChild);

    const ctx = canvas.getContext('2d');
    let width, height;
    let particles = [];

    const config = {
        particleColor1: '#8c52ff',
        particleColor2: '#ff914d',
        particleAmount: 70,
        variantSpeed: 0.8,
        linkRadius: 140,
        mouseRadius: 160
    };

    function resize() {
        width = canvas.width = window.innerWidth;
        height = canvas.height = window.innerHeight;
    }
    window.addEventListener('resize', resize);
    resize();

    let mouse = { x: -1000, y: -1000 };
    window.addEventListener('mousemove', function(e) { mouse.x = e.clientX; mouse.y = e.clientY; });

    function Particle() {
        this.x = Math.random() * width;
        this.y = Math.random() * height;
        this.vx = (Math.random() - 0.5) * config.variantSpeed;
        this.vy = (Math.random() - 0.5) * config.variantSpeed;
        this.size = Math.random() * 2 + 0.8;
        this.color = Math.random() > 0.5 ? config.particleColor1 : config.particleColor2;
    }

    Particle.prototype.update = function() {
        this.x += this.vx;
        this.y += this.vy;
        if (this.x < 0 || this.x > width) this.vx *= -1;
        if (this.y < 0 || this.y > height) this.vy *= -1;
        var dx = mouse.x - this.x;
        var dy = mouse.y - this.y;
        var distance = Math.sqrt(dx * dx + dy * dy);
        if (distance < config.mouseRadius) {
            var force = (config.mouseRadius - distance) / config.mouseRadius;
            this.x -= (dx / distance) * force * 6;
            this.y -= (dy / distance) * force * 6;
        }
    };

    Particle.prototype.draw = function() {
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fillStyle = this.color;
        ctx.fill();
    };

    function initParticles() {
        particles = [];
        var amount = window.innerWidth < 768 ? config.particleAmount / 2 : config.particleAmount;
        for (var i = 0; i < amount; i++) particles.push(new Particle());
    }

    function drawLines() {
        for (var i = 0; i < particles.length; i++) {
            for (var j = i + 1; j < particles.length; j++) {
                var dx = particles[i].x - particles[j].x;
                var dy = particles[i].y - particles[j].y;
                var distance = Math.sqrt(dx * dx + dy * dy);
                if (distance < config.linkRadius) {
                    var opacity = 1 - (distance / config.linkRadius);
                    ctx.beginPath();
                    ctx.strokeStyle = 'rgba(255, 255, 255, ' + (opacity * 0.12) + ')';
                    ctx.lineWidth = 1;
                    ctx.moveTo(particles[i].x, particles[i].y);
                    ctx.lineTo(particles[j].x, particles[j].y);
                    ctx.stroke();
                }
            }
        }
    }

    function animate() {
        ctx.clearRect(0, 0, width, height);
        for (var i = 0; i < particles.length; i++) {
            particles[i].update();
            particles[i].draw();
        }
        drawLines();
        requestAnimationFrame(animate);
    }

    initParticles();
    animate();

    // ─── CUSTOM NAVIGATION ───────────────────────────
    // Detect current page
    var isIndex = !!document.querySelector('#main_index, .index');
    var isSettings = window.location.pathname.indexOf('preferences') !== -1;

    var nav = document.createElement('div');
    nav.id = 'ms-nav';
    nav.innerHTML = '<div class="nav-content">' +
        '<a href="/" class="logo-text">Moritz<span class="gradient-text">soft</span></a>' +
        '<div class="nav-links">' +
            '<a href="/" class="' + (isIndex ? 'active' : '') + '">Search</a>' +
            '<a href="https://moritzsoft.de" target="_blank">Website</a>' +
            '<a href="/preferences"  class="' + (isSettings ? 'active' : '') + '">Settings</a>' +
        '</div>' +
    '</div>';
    document.body.insertBefore(nav, document.body.firstChild);

    // Scroll behavior
    window.addEventListener('scroll', function() {
        if (window.scrollY > 50) {
            nav.classList.add('scrolled');
        } else {
            nav.classList.remove('scrolled');
        }
    });

    // ─── LOGO INJECTION ──────────────────────────────
    var logoContainer = document.querySelector('.logo, .searxng_logo, #main_index .logo');
    if (logoContainer) {
        // Hide default images
        var defaultImgs = logoContainer.querySelectorAll('img');
        defaultImgs.forEach(function(img) { img.style.display = 'none'; });

        var logoImg = document.createElement('img');
        logoImg.id = 'ms-logo-img';
        logoImg.src = '/static/themes/simple/img/moritzsoft-logo.png';
        logoImg.alt = 'MoritzSoft Search';
        logoContainer.appendChild(logoImg);

        // Add subtitle
        var subtitle = document.createElement('p');
        subtitle.id = 'ms-subtitle';
        subtitle.textContent = 'Software ohne Bullshit. Suche ohne Tracking.';
        logoContainer.parentNode.insertBefore(subtitle, logoContainer.nextSibling);
    }

    // ─── CUSTOM FOOTER ───────────────────────────────
    // Remove default footer contents
    var defaultFooter = document.querySelector('footer, .searxng-footer, #footer');
    if (defaultFooter) {
        defaultFooter.innerHTML = '';
        defaultFooter.style.display = 'none';
    }

    // Create our footer
    var footer = document.createElement('div');
    footer.id = 'ms-footer';
    footer.innerHTML = '<div class="footer-legal">' +
        '<p>Moritzsoft &copy; 2026 | Moritz Nickel</p>' +
        '<a href="https://rechtliches.moritzsoft.de" target="_blank" class="legal-link">Rechtliches &amp; Impressum</a>' +
    '</div>';
    document.body.appendChild(footer);

})();
