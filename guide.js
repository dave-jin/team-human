/* === Guide page — copy button + checklist === */

function initCopyButtons() {
  document.querySelectorAll('.guide-copy').forEach(function (btn) {
    const source = document.getElementById(btn.dataset.copyTarget);
    if (!source) return;

    const idle = btn.querySelector('.guide-copy-idle');
    const done = btn.querySelector('.guide-copy-done');
    let resetTimer;

    btn.addEventListener('click', function () {
      const text = source.textContent;

      const showDone = function () {
        idle.hidden = true;
        done.hidden = false;
        btn.classList.add('is-done');
        clearTimeout(resetTimer);
        resetTimer = setTimeout(function () {
          idle.hidden = false;
          done.hidden = true;
          btn.classList.remove('is-done');
        }, 2000);
      };

      if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(showDone).catch(fallbackCopy);
      } else {
        fallbackCopy();
      }

      function fallbackCopy() {
        const ta = document.createElement('textarea');
        ta.value = text;
        ta.setAttribute('readonly', '');
        ta.style.position = 'fixed';
        ta.style.top = '-1000px';
        document.body.appendChild(ta);
        ta.select();
        try { document.execCommand('copy'); showDone(); } catch (e) { /* noop */ }
        document.body.removeChild(ta);
      }
    });
  });
}

function initChecklist() {
  const list = document.getElementById('checklist');
  const doneMsg = document.getElementById('checklist-done');
  if (!list || !doneMsg) return;

  const boxes = list.querySelectorAll('input[type="checkbox"]');

  list.addEventListener('change', function () {
    const allChecked = Array.prototype.every.call(boxes, function (b) { return b.checked; });
    doneMsg.hidden = !allChecked;
  });
}

document.addEventListener('DOMContentLoaded', function () {
  initCopyButtons();
  initChecklist();
});
