(function () {
  const SUPPORTED_LANGS = ['ko', 'en'];
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
    var titleKey = document.querySelector('title').getAttribute('data-i18n-title');
    if (titleKey && translations[titleKey]) {
      document.title = translations[titleKey];
    }
  }

  function updateSwitcher(lang) {
    document.querySelectorAll('.lang-btn').forEach(function (btn) {
      btn.classList.toggle('active', btn.getAttribute('data-lang') === lang);
    });
  }

  function createSwitcher() {
    var nav = document.querySelector('.header nav');
    if (!nav) return;

    var switcher = document.createElement('div');
    switcher.className = 'lang-switcher';

    SUPPORTED_LANGS.forEach(function (lang, i) {
      if (i > 0) {
        var sep = document.createElement('span');
        sep.className = 'lang-sep';
        sep.textContent = '/';
        switcher.appendChild(sep);
      }
      var btn = document.createElement('button');
      btn.className = 'lang-btn';
      btn.setAttribute('data-lang', lang);
      btn.textContent = lang.toUpperCase();
      btn.addEventListener('click', function () {
        setLang(lang);
      });
      switcher.appendChild(btn);
    });

    nav.appendChild(switcher);
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

  document.addEventListener('DOMContentLoaded', function () {
    shuffleTeamCards();
    createSwitcher();
    var lang = getPreferredLang();
    setLang(lang);
  });
})();
