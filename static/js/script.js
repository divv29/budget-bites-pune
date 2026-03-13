// ============================================================
// Budget Bites Pune — Animations & Interactions
// ============================================================

// ── Loader ──────────────────────────────────────────────────
window.addEventListener('load', () => {
  setTimeout(() => {
    const loader = document.querySelector('.loader');
    if (loader) loader.classList.add('hidden');
  }, 1600);
});

// ── Navbar Scroll ────────────────────────────────────────────
const navbar = document.querySelector('.navbar');
window.addEventListener('scroll', () => {
  if (navbar) {
    navbar.classList.toggle('scrolled', window.scrollY > 50);
  }
});

// ── Mobile Nav Toggle ────────────────────────────────────────
const hamburger = document.querySelector('.hamburger');
const navLinks = document.querySelector('.nav-links');
if (hamburger && navLinks) {
  hamburger.addEventListener('click', () => {
    navLinks.classList.toggle('open');
    const spans = hamburger.querySelectorAll('span');
    navLinks.classList.contains('open')
      ? (spans[0].style.transform = 'rotate(45deg) translate(4px, 4px)',
         spans[1].style.opacity = '0',
         spans[2].style.transform = 'rotate(-45deg) translate(4px, -4px)')
      : (spans[0].style.transform = '',
         spans[1].style.opacity = '',
         spans[2].style.transform = '');
  });
  // Close on link click
  navLinks.querySelectorAll('a').forEach(a => a.addEventListener('click', () => {
    navLinks.classList.remove('open');
    hamburger.querySelectorAll('span').forEach(s => { s.style.transform = ''; s.style.opacity = ''; });
  }));
}

// ── Intersection Observer (Fade-up animations) ───────────────
const fadeEls = document.querySelectorAll('.fade-up');
if (fadeEls.length) {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry, i) => {
      if (entry.isIntersecting) {
        setTimeout(() => entry.target.classList.add('visible'), i * 80);
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });
  fadeEls.forEach(el => observer.observe(el));
}

// ── Live Search Autocomplete ─────────────────────────────────
const searchInput = document.getElementById('heroSearch');
const suggestionsBox = document.getElementById('searchSuggestions');

if (searchInput && suggestionsBox) {
  let debounceTimer;
  searchInput.addEventListener('input', () => {
    clearTimeout(debounceTimer);
    const q = searchInput.value.trim();
    if (q.length < 2) {
      suggestionsBox.style.display = 'none';
      return;
    }
    debounceTimer = setTimeout(() => {
      fetch(`/api/search?q=${encodeURIComponent(q)}`)
        .then(r => r.json())
        .then(data => {
          if (!data.length) { suggestionsBox.style.display = 'none'; return; }
          suggestionsBox.innerHTML = data.map(r => `
            <div class="search-suggestion-item" onclick="location.href='/restaurant/${r.id}'">
              <div>
                <div class="suggestion-name">${r.name}</div>
                <div class="suggestion-meta">${r.area} · ${r.cuisine}</div>
              </div>
              <div class="suggestion-meta">★ ${r.rating} · ₹${r.price}</div>
            </div>
          `).join('');
          suggestionsBox.style.display = 'block';
        });
    }, 280);
  });

  document.addEventListener('click', (e) => {
    if (!searchInput.contains(e.target) && !suggestionsBox.contains(e.target)) {
      suggestionsBox.style.display = 'none';
    }
  });

  searchInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      const val = searchInput.value.trim();
      if (val) window.location.href = `/restaurants?search=${encodeURIComponent(val)}`;
    }
  });
}

// ── Flash auto-dismiss ───────────────────────────────────────
setTimeout(() => {
  document.querySelectorAll('.flash-msg').forEach(msg => msg.remove());
}, 4200);

// ── Menu Tab Navigation ──────────────────────────────────────
document.querySelectorAll('.menu-cat-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.menu-cat-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    const target = btn.dataset.cat;
    document.querySelectorAll('.menu-category').forEach(cat => {
      cat.style.display = (target === 'all' || cat.dataset.category === target) ? 'block' : 'none';
    });
  });
});

// ── Star Rating Interactive ──────────────────────────────────
const stars = document.querySelectorAll('.star-rating label');
stars.forEach((star, index) => {
  star.addEventListener('mouseenter', () => {
    stars.forEach((s, i) => {
      s.style.color = i >= stars.length - index - 1 ? 'var(--gold)' : 'var(--text-muted)';
    });
  });
});

// ── Filter Tags (quick cuisine filter on restaurants page) ───
document.querySelectorAll('.tag[data-filter]').forEach(tag => {
  tag.addEventListener('click', () => {
    const param = tag.dataset.filter;
    const type = tag.dataset.type;
    const url = new URL(window.location);
    if (tag.classList.contains('active')) {
      url.searchParams.delete(type);
      tag.classList.remove('active');
    } else {
      document.querySelectorAll(`.tag[data-type="${type}"]`).forEach(t => t.classList.remove('active'));
      url.searchParams.set(type, param);
      tag.classList.add('active');
    }
    window.location.href = url.toString();
  });
});

// ── Parallax on hero bg ──────────────────────────────────────
const heroBg = document.querySelector('.hero-bg');
if (heroBg) {
  window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    heroBg.style.transform = `translateY(${scrolled * 0.3}px)`;
  });
}

// ── Card tilt micro-interaction ──────────────────────────────
document.querySelectorAll('.restaurant-card').forEach(card => {
  card.addEventListener('mousemove', (e) => {
    const rect = card.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width - 0.5;
    const y = (e.clientY - rect.top) / rect.height - 0.5;
    card.style.transform = `translateY(-8px) perspective(600px) rotateY(${x * 4}deg) rotateX(${-y * 4}deg)`;
  });
  card.addEventListener('mouseleave', () => {
    card.style.transform = '';
  });
});

// ── Number counter animation ─────────────────────────────────
function animateCounter(el) {
  const target = parseInt(el.dataset.count);
  let count = 0;
  const step = Math.ceil(target / 50);
  const timer = setInterval(() => {
    count = Math.min(count + step, target);
    el.textContent = count + (el.dataset.suffix || '');
    if (count >= target) clearInterval(timer);
  }, 30);
}

const counterObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      animateCounter(entry.target);
      counterObserver.unobserve(entry.target);
    }
  });
});
document.querySelectorAll('[data-count]').forEach(el => counterObserver.observe(el));

// ── Admin form: price category hint ─────────────────────────
const priceInput = document.getElementById('avg_price_for_two');
const priceHint = document.getElementById('priceHint');
if (priceInput && priceHint) {
  priceInput.addEventListener('input', () => {
    const v = parseInt(priceInput.value);
    if (v <= 300) priceHint.textContent = '₹ Budget';
    else if (v <= 600) priceHint.textContent = '₹₹ Moderate';
    else if (v <= 1000) priceHint.textContent = '₹₹₹ Premium';
    else priceHint.textContent = '₹₹₹₹ Fine Dining';
  });
}
