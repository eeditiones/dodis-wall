// When the Wall Came Down – timeline navigation between documents (arrow keys)
(function () {
    document.addEventListener('keydown', (ev) => {
        if (ev.altKey || ev.ctrlKey || ev.metaKey || ev.shiftKey) { return; }
        const t = ev.target;
        if (t && (t.isContentEditable || /^(input|textarea|select)$/i.test(t.tagName))) { return; }
        const rel = ev.key === 'ArrowLeft' ? 'prev' : (ev.key === 'ArrowRight' ? 'next' : null);
        if (!rel) { return; }
        const link = document.querySelector('.wall-docnav a[rel="' + rel + '"]');
        if (link) {
            ev.preventDefault();
            window.location.href = link.href;
        }
    }, true);
})();

// When the Wall Came Down – chronicle filters
// The filters are Lucene facets evaluated on the server; the selection lives in the query
// parameters (query, country, type, place). Only the place select needs a script to submit.
(function () {
    // older links kept the filters in the hash, e.g. #country-il&type-letter&place-G8:
    // turn them into query parameters
    const legacy = location.hash.replace(/^#/, '').split('&')
        .map((part) => /^(country|type|place)-(.+)$/.exec(part))
        .filter(Boolean);
    if (legacy.length) {
        const url = new URL(location.href);
        legacy.forEach((m) => {
            try { url.searchParams.set(m[1], decodeURIComponent(m[2])); } catch (e) { /* malformed */ }
        });
        url.hash = 'chronicle';
        location.replace(url.href);
        return;
    }

    function init() {
        const form = document.querySelector('.wall-filters');
        if (!form) { return; }
        // height of the sticky filter box, used as scroll offset for the month and event anchors
        // (CSS: scroll-margin-top). On small screens the box is not sticky and needs no offset.
        const offset = () => {
            const sticky = getComputedStyle(form).position === 'sticky';
            document.documentElement.style.setProperty('--wall-filters-offset', sticky ? form.offsetHeight + 'px' : '0px');
        };
        offset();
        new ResizeObserver(offset).observe(form);

        const place = form.querySelector('#wall-place');
        if (place) {
            place.addEventListener('change', () => form.requestSubmit());
        }
        // don't send empty parameters
        form.addEventListener('submit', () => {
            form.querySelectorAll('input[name], select[name]').forEach((el) => {
                if (!el.value) { el.disabled = true; }
            });
        });
        // filter links point to #chronicle, but the browser's jump gets lost while the page above
        // is still growing (images, fonts, web components): keep the section aligned for a few
        // seconds, until the user scrolls
        if (location.hash === '#chronicle') {
            const target = document.getElementById('chronicle') || form;
            let user = false;
            ['wheel', 'touchstart', 'keydown', 'mousedown'].forEach((type) =>
                window.addEventListener(type, () => { user = true; }, { once: true, passive: true }));
            const align = () => { if (!user) { target.scrollIntoView({ block: 'start', behavior: 'instant' }); } };
            const observer = new ResizeObserver(align);
            observer.observe(document.body);
            window.addEventListener('load', align);
            setTimeout(() => observer.disconnect(), 3000);
        }
        // re-enable after navigating back (bfcache)
        window.addEventListener('pageshow', () => {
            form.querySelectorAll('[disabled]').forEach((el) => { el.disabled = false; });
        });
    }
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
