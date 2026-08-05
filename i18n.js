(function () {
  const SUPPORTED_LANGS = ['en', 'ko'];
  const DEFAULT_LANG = 'en';
  const STORAGE_KEY = 'team-human-lang';

  function getPreferredLang() {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored && SUPPORTED_LANGS.includes(stored)) return stored;
    return DEFAULT_LANG;
  }

  function setLang(lang) {
    localStorage.setItem(STORAGE_KEY, lang);
    document.documentElement.lang = lang;
    applyTranslations(lang);
    updateSwitcher(lang);
  }

  async function loadTranslations(lang) {
    const res = await fetch(`i18n/${lang}.json`);
    return res.json();
  }

  async function applyTranslations(lang) {
    const translations = await loadTranslations(lang);
    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      var key = el.getAttribute('data-i18n');
      if (translations[key] !== undefined) {
        el.textContent = translations[key];
      }
    });
    document.querySelectorAll('[data-i18n-placeholder]').forEach(function (el) {
      var key = el.getAttribute('data-i18n-placeholder');
      if (translations[key] !== undefined) {
        el.placeholder = translations[key];
      }
    });
    document.querySelectorAll('[data-i18n-alt]').forEach(function (el) {
      var key = el.getAttribute('data-i18n-alt');
      if (translations[key] !== undefined) {
        el.alt = translations[key];
      }
    });
    var titleKey = document.querySelector('title').getAttribute('data-i18n-title');
    if (titleKey && translations[titleKey]) {
      document.title = translations[titleKey];
    }
  }

  function updateSwitcher(lang) {
    var select = document.querySelector('.lang-select');
    if (select) select.value = lang;
  }

  function createSwitcher() {
    var nav = document.querySelector('.header nav');
    if (!nav) return;

    var select = document.createElement('select');
    select.className = 'lang-select';

    SUPPORTED_LANGS.forEach(function (lang) {
      var option = document.createElement('option');
      option.value = lang;
      var labels = { en: 'English', ko: '한국어' };
      option.textContent = labels[lang] || lang.toUpperCase();
      select.appendChild(option);
    });

    select.addEventListener('change', function () {
      setLang(select.value);
    });

    nav.appendChild(select);
  }

  function shuffleTeamCards() {
    var grid = document.querySelector('.team-grid');
    if (!grid) return;
    var cards = Array.from(grid.children);
    for (var i = cards.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      grid.appendChild(cards[j]);
      cards.splice(j, 1, cards[i]);
    }
  }

  function initHeroSlider() {
    var slider = document.querySelector('.hero-slider');
    if (!slider) return;
    var track = slider.querySelector('.hero-slider-track');
    var slides = Array.from(track.querySelectorAll('.hero-slide'));
    var dots = Array.from(slider.querySelectorAll('.hero-slider-dot'));
    var prev = slider.querySelector('.hero-slider-arrow--prev');
    var next = slider.querySelector('.hero-slider-arrow--next');
    if (!slides.length) return;

    function currentIndex() {
      var w = track.clientWidth;
      if (!w) return 0;
      return Math.round(track.scrollLeft / w);
    }

    function pauseIframesExcept(idx) {
      slides.forEach(function (slide, i) {
        if (i === idx) return;
        var iframe = slide.querySelector('iframe');
        if (!iframe || !iframe.contentWindow) return;
        try {
          iframe.contentWindow.postMessage('{"event":"command","func":"pauseVideo","args":""}', '*');
        } catch (e) {}
      });
    }

    function update() {
      var idx = currentIndex();
      dots.forEach(function (dot, i) {
        var active = i === idx;
        dot.classList.toggle('is-active', active);
        dot.setAttribute('aria-selected', active ? 'true' : 'false');
      });
      pauseIframesExcept(idx);
    }

    function goTo(idx) {
      var clamped = Math.max(0, Math.min(slides.length - 1, idx));
      var target = slides[clamped];
      if (!target) return;
      track.scrollTo({ left: target.offsetLeft, behavior: 'smooth' });
    }

    dots.forEach(function (dot) {
      dot.addEventListener('click', function () {
        goTo(parseInt(dot.getAttribute('data-index'), 10));
      });
    });

    if (prev) prev.addEventListener('click', function () { goTo(currentIndex() - 1); });
    if (next) next.addEventListener('click', function () { goTo(currentIndex() + 1); });

    var scrollTimer;
    track.addEventListener('scroll', function () {
      clearTimeout(scrollTimer);
      scrollTimer = setTimeout(update, 80);
    });

    slider.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowLeft') { e.preventDefault(); goTo(currentIndex() - 1); }
      else if (e.key === 'ArrowRight') { e.preventDefault(); goTo(currentIndex() + 1); }
    });
    slider.setAttribute('tabindex', '0');

    window.addEventListener('resize', function () {
      goTo(currentIndex());
    });

    update();
  }

  function initContactForm() {
    var form = document.querySelector('.contact-form');
    if (!form) return;

    var fields = form.querySelector('.contact-fields');
    var submit = form.querySelector('.contact-submit');
    var idle = form.querySelector('.contact-submit-idle');
    var busy = form.querySelector('.contact-submit-busy');
    var statusOk = form.querySelector('.contact-status--success');
    var statusErr = form.querySelector('.contact-status--error');

    function setBusy(isBusy) {
      submit.disabled = isBusy;
      if (idle) idle.hidden = isBusy;
      if (busy) busy.hidden = !isBusy;
    }

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      if (statusErr) statusErr.hidden = true;
      setBusy(true);

      fetch(form.action, {
        method: 'POST',
        body: new FormData(form),
        headers: { Accept: 'application/json' }
      }).then(function (res) {
        if (!res.ok) throw new Error('Submission failed');
        form.reset();
        if (fields) fields.hidden = true;
        if (statusOk) statusOk.hidden = false;
      }).catch(function () {
        if (statusErr) statusErr.hidden = false;
      }).finally(function () {
        setBusy(false);
      });
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    shuffleTeamCards();
    createSwitcher();
    initHeroSlider();
    initContactForm();
    var lang = getPreferredLang();
    setLang(lang);
  });
})();
