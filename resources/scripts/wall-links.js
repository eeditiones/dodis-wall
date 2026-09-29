// When the Wall Came Down – person pages: external links (Metagrid, Wikidata) and portrait (Wikimedia Commons)
(function () {
    const METAGRID = 'https://api.metagrid.ch/widget/dodis/person/';
    const WIKIDATA = 'https://query.wikidata.org/sparql';

    function lang() {
        const l = (document.documentElement.lang || navigator.language || 'en').substring(0, 2).toLowerCase();
        return l === 'de' ? 'de' : 'en';
    }

    // compare links independent of protocol, "www." and trailing slash
    function norm(url) {
        return String(url).trim().replace(/^https?:\/\//, '').replace(/^www\./, '').replace(/\/+$/, '').toLowerCase();
    }

    function jsonp(url, timeout) {
        return new Promise((resolve, reject) => {
            const cb = 'wallMetagrid' + Date.now() + Math.floor(Math.random() * 1000);
            const script = document.createElement('script');
            const timer = setTimeout(() => { cleanup(); reject(new Error('timeout')); }, timeout || 8000);
            function cleanup() {
                clearTimeout(timer);
                delete window[cb];
                script.remove();
            }
            window[cb] = (data) => { cleanup(); resolve(data); };
            script.onerror = () => { cleanup(); reject(new Error('load error')); };
            script.src = url + (url.includes('?') ? '&' : '?') + 'callback=' + cb;
            document.head.appendChild(script);
        });
    }

    async function metagrid(id) {
        const data = await jsonp(METAGRID + encodeURIComponent(id) + '.json?include=true&language=' + lang());
        const entries = Array.isArray(data) ? data[0] : data;
        if (!entries || typeof entries !== 'object') { return []; }
        return Object.keys(entries).map((name) => {
            const v = entries[name];
            const url = typeof v === 'string' ? v : (v && v.url);
            return url ? { name: name, url: url, title: v && v.short_description } : null;
        }).filter(Boolean);
    }

    async function wikidata(id) {
        const query = `
            SELECT ?item ?image ?gnd ?viaf ?wpde ?wpen WHERE {
                VALUES ?id { "${id}" "P${id}" }
                ?item wdt:P701 ?id .
                OPTIONAL { ?item wdt:P18 ?image }
                OPTIONAL { ?item wdt:P227 ?gnd }
                OPTIONAL { ?item wdt:P214 ?viaf }
                OPTIONAL { ?wpde schema:about ?item ; schema:isPartOf <https://de.wikipedia.org/> }
                OPTIONAL { ?wpen schema:about ?item ; schema:isPartOf <https://en.wikipedia.org/> }
            } LIMIT 1`;
        const resp = await fetch(WIKIDATA + '?format=json&query=' + encodeURIComponent(query), {
            headers: { Accept: 'application/sparql-results+json' }
        });
        if (!resp.ok) { return null; }
        const json = await resp.json();
        const b = json.results && json.results.bindings && json.results.bindings[0];
        if (!b) { return null; }
        const v = (k) => b[k] && b[k].value;
        const qid = v('item').replace(/^.*\//, '');
        const links = [{ name: 'Wikidata', url: 'https://www.wikidata.org/wiki/' + qid, id: qid }];
        const wp = lang() === 'de' ? [['wpde', 'Wikipedia (de)'], ['wpen', 'Wikipedia (en)']] : [['wpen', 'Wikipedia (en)'], ['wpde', 'Wikipedia (de)']];
        wp.forEach(([k, name]) => { if (v(k)) { links.push({ name: name, url: v(k) }); } });
        if (v('gnd')) { links.push({ name: 'GND', url: 'https://d-nb.info/gnd/' + v('gnd'), id: v('gnd') }); }
        if (v('viaf')) { links.push({ name: 'VIAF', url: 'https://viaf.org/viaf/' + v('viaf'), id: v('viaf') }); }
        return { links: links, image: v('image') };
    }

    function addLink(list, seen, link) {
        const key = norm(link.url);
        if (seen.has(key)) { return; }
        seen.add(key);
        const li = document.createElement('li');
        li.dataset.url = link.url;
        const a = document.createElement('a');
        a.href = link.url;
        a.target = '_blank';
        a.rel = 'noopener';
        if (link.title) { a.title = link.title; }
        const name = document.createElement('span');
        name.className = 'reg-link-name';
        name.textContent = link.name;
        const id = document.createElement('span');
        id.className = 'reg-link-id';
        id.textContent = link.id || link.url.replace(/^https?:\/\/(www\.)?/, '').replace(/\/+$/, '');
        a.append(name, id);
        li.appendChild(a);
        list.appendChild(li);
    }

    function addPortrait(section, imageUrl, name) {
        const person = section.closest('section.person') || section.parentElement;
        if (!person || person.querySelector('.reg-portrait')) { return; }
        // P18 values are Special:FilePath URLs; ask Commons for a thumbnail
        const file = decodeURIComponent(imageUrl.replace(/^.*\/Special:FilePath\//, ''));
        const fig = document.createElement('figure');
        fig.className = 'reg-portrait';
        const img = document.createElement('img');
        img.src = 'https://commons.wikimedia.org/wiki/Special:FilePath/' + encodeURIComponent(file) + '?width=320';
        img.alt = name || '';
        img.loading = 'lazy';
        img.onerror = () => fig.remove();
        const cap = document.createElement('figcaption');
        const a = document.createElement('a');
        a.href = 'https://commons.wikimedia.org/wiki/File:' + encodeURIComponent(file.replace(/ /g, '_'));
        a.target = '_blank';
        a.rel = 'noopener';
        a.textContent = 'Wikimedia Commons';
        cap.appendChild(a);
        fig.append(img, cap);
        const heading = person.querySelector('h1, h2');
        if (heading) { heading.after(fig); } else { person.prepend(fig); }
    }

    async function init() {
        const section = document.querySelector('.reg-links[data-dodis]');
        if (!section) { return; }
        const id = section.dataset.dodis;
        const list = section.querySelector('.reg-link-list');
        const seen = new Set(Array.from(list.querySelectorAll('li[data-url]')).map((li) => norm(li.dataset.url)));
        seen.add(norm('https://dodis.ch/P' + id));
        const heading = (section.closest('section.person') || document).querySelector('h1, h2');
        const name = heading ? heading.textContent.trim() : '';

        const [wd, mg] = await Promise.allSettled([wikidata(id), metagrid(id)]);
        if (wd.status === 'fulfilled' && wd.value) {
            wd.value.links.forEach((l) => addLink(list, seen, l));
            if (wd.value.image) { addPortrait(section, wd.value.image, name); }
        }
        if (mg.status === 'fulfilled') {
            mg.value
                .filter((l) => !/dodis\.ch/i.test(l.url))
                .sort((a, b) => a.name.localeCompare(b.name))
                .forEach((l) => addLink(list, seen, l));
        }
        const status = section.querySelector('.reg-links-status');
        if (status && list.children.length > 1) { status.hidden = false; }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
