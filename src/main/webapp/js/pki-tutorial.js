/**
 * pki-tutorial.js - Interactive PKI Concepts Tutorial (v1.0)
 * Vanilla JS port of the UC4 tutorial mockup (originally React).
 * Tailwind CSS, dark mode and i18n aware. No backend calls.
 */

/* ------------------------------------------------------------------ */
/* Helpers                                                             */
/* ------------------------------------------------------------------ */

function tl(key, fallback) {
    // NOTE: i18n.js declares `translations` with `const` at script top-level, so it
    // lives in the shared global lexical scope, not as a `window` property - reference
    // it directly (not via `window.translations`, which is always undefined).
    const currentLang = localStorage.getItem('snm-lang') || 'en';
    return (typeof translations !== 'undefined' && translations[currentLang] && translations[currentLang][key]) ? translations[currentLang][key] : fallback;
}

function computeIA(parentIA, issuerSF) {
    return Math.max(0, Math.round(parentIA * (1 - issuerSF / 10)));
}

function iaLabel(score) {
    if (score === 0) return tl('tut.lbl_unverified', 'unverified');
    if (score <= 3) return tl('tut.lbl_bad', 'bad');
    if (score <= 6) return tl('tut.lbl_enough', 'enough?');
    if (score <= 8) return tl('tut.lbl_nice', 'nice');
    if (score === 9) return tl('tut.lbl_good', 'good');
    return tl('tut.lbl_perfect', 'perfect');
}

/* Tailwind class helpers for score colors */
function barColorClass(score) {
    if (score === 0) return 'bg-gray-400';
    if (score <= 3) return 'bg-red-500';
    if (score <= 6) return 'bg-amber-500';
    if (score <= 8) return 'bg-blue-600';
    if (score === 9) return 'bg-emerald-600';
    return 'bg-green-500';
}

function labelColorClass(score) {
    if (score === 0) return 'text-gray-500 dark:text-gray-400';
    if (score <= 3) return 'text-red-500';
    if (score <= 6) return 'text-amber-600 dark:text-amber-500';
    if (score <= 8) return 'text-blue-600 dark:text-blue-400';
    return 'text-green-700 dark:text-green-400';
}

function badgeClass(score) {
    if (score === 0) return 'bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-300';
    if (score <= 3) return 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400';
    if (score <= 6) return 'bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400';
    if (score <= 8) return 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400';
    return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400';
}

function sfColorHex(sf) {
    if (sf <= 3) return '#10b981';
    if (sf <= 6) return '#f59e0b';
    return '#ef4444';
}

function sfTextClass(sf) {
    if (sf <= 3) return 'text-green-600 dark:text-green-400';
    if (sf <= 6) return 'text-amber-600 dark:text-amber-500';
    return 'text-red-500';
}

/* HTML snippet builders */
function iaBarHTML(score, h) {
    let segs = '';
    for (let i = 0; i < 10; i++) {
        segs += `<span class="flex-1 ${h || 'h-1'} rounded-sm ${i < score ? barColorClass(score) : 'bg-gray-200 dark:bg-gray-700'}"></span>`;
    }
    return `<div class="flex gap-0.5 w-full">${segs}</div>`;
}

function scoreBadgeHTML(score) {
    const text = score === 0 ? iaLabel(score) : `"${iaLabel(score)}"`;
    return `<span class="inline-flex px-2 py-0.5 rounded-full text-xs font-semibold whitespace-nowrap ${badgeClass(score)}">${text}</span>`;
}

function chainNodeHTML({name, ia, isYou, isLast}) {
    const circle = isYou
        ? 'bg-blue-600 text-white'
        : 'bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400';
    const ring = isLast ? `box-shadow:0 0 0 2px var(--tw-ring-offset-color,#fff),0 0 0 4px ${ia >= 9 ? '#10b981' : ia >= 7 ? '#2563eb' : ia >= 4 ? '#f59e0b' : '#ef4444'};` : '';
    const sub = isYou
        ? `<div class="text-[0.65rem] text-gray-500 dark:text-gray-400">${tl('tut.direct', 'direct')}</div>`
        : `<div class="font-mono text-xs font-bold mt-0.5 ${labelColorClass(ia)}">${ia}/10</div>
           <div class="mt-1 w-16 mx-auto">${iaBarHTML(ia, 'h-1')}</div>
           <div class="mt-1">${scoreBadgeHTML(ia)}</div>`;
    return `
        <div class="flex flex-col items-center gap-2">
            <div class="w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0 transition-all ${circle}" style="${ring}">
                <i class="fas fa-user"></i>
            </div>
            <div class="text-center min-w-[64px]">
                <div class="text-sm font-bold ${isYou ? 'text-blue-600 dark:text-blue-400' : ''}">${name}</div>
                ${sub}
            </div>
        </div>`;
}

function arrowHTML(label) {
    return `
        <div class="flex flex-col items-center pt-3">
            <span class="text-gray-300 dark:text-gray-600 text-xl leading-none">&rarr;</span>
            ${label ? `<span class="text-[0.62rem] text-gray-400 mt-1">${label}</span>` : ''}
        </div>`;
}

function miniNodeHTML(name, ia, isYou, highlight) {
    const circle = isYou ? 'bg-blue-600 text-white' : 'bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400';
    const ring = highlight ? `box-shadow:0 0 0 2px #fff,0 0 0 3.5px ${ia >= 9 ? '#10b981' : ia >= 7 ? '#2563eb' : ia >= 4 ? '#f59e0b' : '#ef4444'};` : '';
    return `
        <div class="text-center">
            <div class="w-8 h-8 rounded-full flex items-center justify-center text-[0.6rem] font-bold mx-auto ${circle}" style="${ring}">${name}</div>
            ${ia !== null ? `<div class="text-[0.6rem] font-mono font-bold mt-0.5 ${labelColorClass(ia)}">${ia}</div>` : ''}
        </div>`;
}

/* ------------------------------------------------------------------ */
/* Static sections                                                     */
/* ------------------------------------------------------------------ */

function renderScoreRows() {
    const rows = [
        {score: 10, range: '10', descKey: 'tut.row_10', desc: 'You shook hands. You know this person.'},
        {score: 9, range: '9', descKey: 'tut.row_9', desc: 'About as good as it gets without meeting in person.'},
        {score: 8, range: '7–8', descKey: 'tut.row_78', desc: "Solid. You'd lend them a charger."},
        {score: 6, range: '4–6', descKey: 'tut.row_46', desc: 'A friend of a friend. Could be fine, could be weird.'},
        {score: 3, range: '1–3', descKey: 'tut.row_13', desc: 'A stranger vouched for by strangers. Proceed carefully.'},
        {score: 0, range: '0', descKey: 'tut.row_0', desc: 'No idea who this is. They just showed up.'}
    ];

    const container = document.getElementById('score-rows');
    container.innerHTML = rows.map(r => `
        <div class="flex items-center gap-3 px-3.5 py-2.5 rounded-lg bg-gray-50 dark:bg-gray-900/50 border border-gray-100 dark:border-gray-700 flex-wrap">
            <span class="font-mono font-bold text-sm w-8 text-right flex-shrink-0 ${labelColorClass(r.score)}">${r.range}</span>
            <div class="w-32 flex-shrink-0">${iaBarHTML(r.score, 'h-1.5')}</div>
            ${scoreBadgeHTML(r.score)}
            <span class="text-xs text-gray-500 dark:text-gray-400">${tl(r.descKey, r.desc)}</span>
        </div>
    `).join('');
}

function renderStaticChain() {
    const nodes = [
        {name: tl('tut.you', 'You'), ia: 10, isYou: true},
        {name: 'Alice', ia: 10},
        {name: 'Bob', ia: 8},
        {name: 'Clara', ia: 4, isLast: true}
    ];
    document.getElementById('static-chain').innerHTML = nodes
        .map((n, i) => (i > 0 ? arrowHTML(tl('tut.certifies', 'certifies')) : '') + chainNodeHTML(n))
        .join('');
}

/* ------------------------------------------------------------------ */
/* Interactive playground                                              */
/* ------------------------------------------------------------------ */

function renderPlayground() {
    const aliceSF = Number(document.getElementById('alice-sf').value);
    const bobSF = Number(document.getElementById('bob-sf').value);
    const claraSF = Number(document.getElementById('clara-sf').value);

    const aliceIA = 10;
    const bobIA = computeIA(aliceIA, aliceSF);
    const claraIA = computeIA(bobIA, bobSF);
    const davidIA = computeIA(claraIA, claraSF);

    // slider value labels + accent colors
    [['alice', aliceSF], ['bob', bobSF], ['clara', claraSF]].forEach(([who, sf]) => {
        const valEl = document.getElementById(`${who}-sf-val`);
        valEl.textContent = `${sf}/10`;
        valEl.className = `font-mono text-sm font-bold ${sfTextClass(sf)}`;
        document.getElementById(`${who}-sf`).style.accentColor = sfColorHex(sf);
    });

    // chain
    const nodes = [
        {name: tl('tut.you', 'You'), ia: 10, isYou: true},
        {name: 'Alice', ia: aliceIA},
        {name: 'Bob', ia: bobIA},
        {name: 'Clara', ia: claraIA},
        {name: 'David', ia: davidIA, isLast: true}
    ];
    document.getElementById('play-chain').innerHTML = nodes
        .map((n, i) => (i > 0 ? arrowHTML('') : '') + chainNodeHTML(n))
        .join('');

    // formula
    const verified = tl('tut.verified_by_you', '(verified directly by you)');
    document.getElementById('play-formula').innerHTML = `
        <div>Alice = <strong>10</strong> <span class="font-sans text-xs text-gray-500 dark:text-gray-400">${verified}</span></div>
        <div>Bob&nbsp;&nbsp;&nbsp; = ${aliceIA} &times; (1 &minus; ${aliceSF}/10) = <strong class="${labelColorClass(bobIA)}">${bobIA}</strong></div>
        <div>Clara = ${bobIA} &times; (1 &minus; ${bobSF}/10) = <strong class="${labelColorClass(claraIA)}">${claraIA}</strong></div>
        <div>David = ${claraIA} &times; (1 &minus; ${claraSF}/10) = <strong class="${labelColorClass(davidIA)}">${davidIA}</strong></div>
    `;
}

/* ------------------------------------------------------------------ */
/* Factor demos                                                        */
/* ------------------------------------------------------------------ */

function renderIAResult(prefix, score) {
    const num = document.getElementById(`${prefix}-ia-num`);
    num.textContent = score;
    num.className = `font-mono font-bold text-sm ${labelColorClass(score)}`;
    document.getElementById(`${prefix}-ia-bar`).innerHTML = iaBarHTML(score, 'h-1');
    const badge = document.getElementById(`${prefix}-ia-badge`);
    badge.outerHTML = scoreBadgeHTML(score).replace('<span', `<span id="${prefix}-ia-badge"`);
}

/* Factor 1: chain length */
function renderFactor1() {
    const hops = Number(document.getElementById('f1-hops').value);
    const ias = [10];
    for (let i = 0; i < hops; i++) ias.push(computeIA(ias[ias.length - 1], 3));
    const finalIA = ias[ias.length - 1];

    document.getElementById('f1-hops-val').textContent = hops;

    let viz = miniNodeHTML(tl('tut.you', 'You'), 10, true, false);
    for (let i = 0; i < hops; i++) {
        viz += `<span class="text-gray-300 dark:text-gray-600 text-sm">&rarr;</span>` + miniNodeHTML(`P${i + 1}`, ias[i + 1], false, false);
    }
    viz += `<span class="text-gray-300 dark:text-gray-600 text-sm">&rarr;</span>` + miniNodeHTML('?', finalIA, false, true);
    document.getElementById('f1-viz').innerHTML = viz;

    renderIAResult('f1', finalIA);
}

/* Factor 2: SF of issuer */
function renderFactor2() {
    const sf = Number(document.getElementById('f2-sf').value);
    const ia = computeIA(10, sf);

    const valEl = document.getElementById('f2-sf-val');
    valEl.textContent = `${sf}/10`;
    valEl.className = `font-mono font-bold ${sfTextClass(sf)}`;
    document.getElementById('f2-sf').style.accentColor = sfColorHex(sf);

    document.getElementById('f2-viz').innerHTML =
        miniNodeHTML(tl('tut.you', 'You'), 10, true, false) +
        `<div class="flex flex-col items-center">
            <span class="text-gray-300 dark:text-gray-600 text-sm">&rarr;</span>
            <span class="text-[0.58rem] font-semibold ${sfTextClass(sf)}">SF=${sf}</span>
        </div>` +
        miniNodeHTML('Alice', 10, false, false) +
        `<span class="text-gray-300 dark:text-gray-600 text-sm">&rarr;</span>` +
        miniNodeHTML('Bob', ia, false, true);

    renderIAResult('f2', ia);
}

/* Factor 3: validity */
function renderFactor3() {
    const age = Number(document.getElementById('f3-age').value);
    const expired = age > 12;

    document.getElementById('f3-age-val').textContent = `${age} mo`;
    document.getElementById('f3-age-val').className = `font-mono font-bold ${expired ? 'text-red-500' : 'text-green-600 dark:text-green-400'}`;
    document.getElementById('f3-age').style.accentColor = expired ? '#ef4444' : '#10b981';

    const status = document.getElementById('f3-status');
    status.textContent = expired ? tl('tut.f3_expired', 'Expired') : tl('tut.f3_valid', 'Valid');
    status.className = `px-2 py-0.5 rounded-full text-xs font-semibold transition-colors ${expired
        ? 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400'
        : 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400'}`;

    document.getElementById('f3-age-note').textContent = `${tl('tut.f3_issued', 'Issued')} ${age} ${age === 1 ? tl('tut.month', 'month') : tl('tut.months', 'months')} ${tl('tut.ago', 'ago')}`;

    const bar = document.getElementById('f3-bar');
    bar.style.width = `${Math.min(age / 24 * 100, 100)}%`;
    bar.className = `h-full rounded-full transition-all ${expired ? 'bg-red-500' : 'bg-green-500'}`;

    const counts = document.getElementById('f3-counts');
    counts.textContent = expired ? tl('tut.f3_no', 'No. Certificate expired.') : tl('tut.f3_yes', 'Yes');
    counts.className = `font-bold text-sm transition-colors ${expired ? 'text-red-500' : 'text-green-700 dark:text-green-400'}`;
}

/* Factor 4: direct exchange */
let f4Direct = false;

function renderFactor4() {
    const directIA = 10;
    const networkIA = computeIA(computeIA(10, 3), 3);
    const ia = f4Direct ? directIA : networkIA;

    const btnNet = document.getElementById('f4-btn-network');
    const btnDir = document.getElementById('f4-btn-direct');
    btnNet.className = `flex-1 py-2 rounded-lg border-2 font-semibold text-xs transition-all ${!f4Direct
        ? 'border-blue-600 bg-blue-50 text-blue-600 dark:bg-blue-900/20 dark:text-blue-400'
        : 'border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-500 dark:text-gray-400'}`;
    btnDir.className = `flex-1 py-2 rounded-lg border-2 font-semibold text-xs transition-all ${f4Direct
        ? 'border-green-700 bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400'
        : 'border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-500 dark:text-gray-400'}`;

    document.getElementById('f4-card').className = `border rounded-lg p-4 flex flex-col gap-3 transition-colors ${f4Direct
        ? 'border-green-200 dark:border-green-900/40 bg-green-50 dark:bg-green-900/10'
        : 'border-gray-200 dark:border-gray-700'}`;

    const viz = document.getElementById('f4-viz');
    if (f4Direct) {
        viz.className = 'rounded-lg px-3.5 py-3 flex flex-col items-center gap-2 transition-colors bg-green-100 dark:bg-green-900/20';
        viz.innerHTML = `
            <div class="text-xs font-semibold text-green-700 dark:text-green-400">${tl('tut.f4_in_person', 'You verified them in person')}</div>
            <div class="flex items-center gap-2.5">
                ${miniNodeHTML(tl('tut.you', 'You'), null, true, false)}
                <span class="text-xs font-semibold text-green-700 dark:text-green-400">${tl('tut.f4_key_exchange', 'key exchange')}</span>
                ${miniNodeHTML('Bob', null, false, true).replace('bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400', 'bg-green-700 text-white')}
            </div>`;
    } else {
        viz.className = 'rounded-lg px-3.5 py-3 flex flex-col items-center gap-2 transition-colors bg-gray-50 dark:bg-gray-900/50';
        viz.innerHTML = `
            <div class="text-xs text-gray-500 dark:text-gray-400">${tl('tut.you', 'You')} &rarr; Alice &rarr; Bob (2 hops, SF=3)</div>
            <div class="flex items-center gap-1.5">
                ${miniNodeHTML(tl('tut.you', 'You'), 10, true, false)}
                <span class="text-gray-300 dark:text-gray-600 text-sm">&rarr;</span>
                ${miniNodeHTML('Alice', computeIA(10, 3), false, false)}
                <span class="text-gray-300 dark:text-gray-600 text-sm">&rarr;</span>
                ${miniNodeHTML('Bob', networkIA, false, true)}
            </div>`;
    }

    renderIAResult('f4', ia);
}

/* ------------------------------------------------------------------ */
/* Bootstrapping                                                       */
/* ------------------------------------------------------------------ */

document.addEventListener('DOMContentLoaded', () => {
    renderScoreRows();
    renderStaticChain();
    renderPlayground();
    renderFactor1();
    renderFactor2();
    renderFactor3();
    renderFactor4();

    ['alice-sf', 'bob-sf', 'clara-sf'].forEach(id =>
        document.getElementById(id).addEventListener('input', renderPlayground));
    document.getElementById('f1-hops').addEventListener('input', renderFactor1);
    document.getElementById('f2-sf').addEventListener('input', renderFactor2);
    document.getElementById('f3-age').addEventListener('input', renderFactor3);
    document.getElementById('f4-btn-network').addEventListener('click', () => { f4Direct = false; renderFactor4(); });
    document.getElementById('f4-btn-direct').addEventListener('click', () => { f4Direct = true; renderFactor4(); });

    // re-render dynamic parts when the language changes
    window.addEventListener('storage', e => {
        if (e.key === 'snm-lang') {
            renderScoreRows(); renderStaticChain(); renderPlayground();
            renderFactor1(); renderFactor2(); renderFactor3(); renderFactor4();
        }
    });
});
