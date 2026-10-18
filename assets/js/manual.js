/* Progressive enhancement: the text and navigation work without JavaScript. */
document.querySelectorAll('.print-button').forEach(button => {
  button.hidden = false;
  button.addEventListener('click', () => window.print());
});
const disclosure = document.querySelector('.contents-disclosure');
if (disclosure) {
  const smallScreen = window.matchMedia('(max-width: 899px)');
  const updateContents = () => { disclosure.open = !smallScreen.matches; };
  updateContents();
  smallScreen.addEventListener('change', updateContents);
}
const form = document.querySelector('[data-search-form]');
if (form) {
  const input = form.querySelector('input');
  const status = document.querySelector('[data-search-status]');
  const results = document.querySelector('[data-search-results]');
  const normalize = value => value.normalize('NFC').toLocaleLowerCase();
  let indexPromise;
  let requestNumber = 0;
  async function search() {
    const currentRequest = ++requestNumber;
    const query = input.value.trim();
    results.replaceChildren();
    if (!query) { status.textContent = 'Search a term or rule number / 請輸入詞語或規則編號'; return; }
    status.textContent = 'Searching / 搜尋中…';
    try {
      indexPromise ||= fetch(form.dataset.indexUrl).then(response => {
        if (!response.ok) throw new Error('Search index unavailable');
        return response.json();
      });
      const index = await indexPromise;
      if (currentRequest !== requestNumber) return;
      const terms = normalize(query).split(/\s+/u);
      const matches = index.filter(rule => {
        const text = normalize([rule.number, rule.zh_title, rule.en_title, rule.zh_text, rule.en_text].join(' '));
        return terms.every(term => text.includes(term));
      });
      status.textContent = `${matches.length} result${matches.length === 1 ? '' : 's'} / ${matches.length} 筆結果`;
      matches.forEach(rule => {
        const article = document.createElement('article');
        article.className = 'search-result';
        const heading = document.createElement('h2');
        const link = document.createElement('a');
        link.href = rule.url;
        link.textContent = `${rule.number} ${rule.zh_title} / ${rule.en_title}`;
        heading.append(link);
        const excerpt = document.createElement('p');
        const text = /[\u3400-\u9fff]/u.test(query) ? rule.zh_text : rule.en_text;
        const position = Math.max(0, normalize(text).indexOf(terms[0]) - 35);
        excerpt.textContent = (position ? '…' : '') + text.slice(position, position + 190).trim() + (text.length > position + 190 ? '…' : '');
        article.append(heading, excerpt);
        results.append(article);
      });
    } catch (error) {
      if (currentRequest !== requestNumber) return;
      indexPromise = undefined;
      status.textContent = 'Search could not load. Please try again or browse the chapter contents. / 搜尋暫時無法載入，請重試或瀏覽目錄。';
    }
  }
  form.addEventListener('submit', event => { event.preventDefault(); search(); });
  input.value = new URLSearchParams(window.location.search).get('q') || '';
  if (input.value) search();
}
