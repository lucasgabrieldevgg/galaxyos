#!/usr/bin/env node
/**
 * GalaxyOS — feed contract test (rung 3-lite do ladder roku-craft).
 *
 * O que é testado aqui:
 *  1. As REGRAS: porta fiel do validador BrightScript (src/source/feed-validate.brs),
 *     com whitelist/limites EXTRAÍDOS dos próprios .brs (sem divergência possível).
 *  2. Os FIXTURES: JSON válido + hostis (vazio, tipo errado, id inválido,
 *     strings gigantes, badge inválido, campo ausente).
 *  3. O ARQUIVO REAL publicado (prototype/feeds/modules.json).
 *
 * O que NÃO é testado aqui (declarado): o runtime .brs em si — isso é rung 4
 * (smoke no device). Equivalência lógica revisada linha a linha.
 */
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const configBrs = fs.readFileSync(path.join(root, 'src/source/config.brs'), 'utf8');
const validateBrs = fs.readFileSync(path.join(root, 'src/source/feed-validate.brs'), 'utf8');

/* ── constantes extraídas dos .brs (fonte da verdade) ── */
const maxModules = Number(configBrs.match(/maxModules:\s*(\d+)/)[1]);
const maxTitleLen = Number(configBrs.match(/maxTitleLen:\s*(\d+)/)[1]);
const maxDescLen = Number(configBrs.match(/maxDescLen:\s*(\d+)/)[1]);
const allowedIds = [...validateBrs.match(/allowedIds = \{([^}]*)\}/)[1].matchAll(/([a-z]+):\s*true/g)].map(m => m[1]);

/* ── porta fiel de validateModules() ── */
function validateModules(json) {
    if (json === null || json === undefined) return null;
    if (typeof json !== 'object' || Array.isArray(json)) return null;

    const raw = json.modules;
    if (!Array.isArray(raw)) return null;

    if (raw.length === 0 || raw.length > maxModules) return null;

    const out = [];
    for (const item of raw) {
        if (item === null || typeof item !== 'object' || Array.isArray(item)) return null;

        const id = item.id;
        if (typeof id !== 'string' || !allowedIds.includes(id)) return null;

        for (const f of ['title_pt', 'title_en', 'desc_pt', 'desc_en']) {
            if (typeof item[f] !== 'string') return null;
        }
        for (const f of ['title_pt', 'title_en']) {
            if (item[f].length === 0 || item[f].length > maxTitleLen) return null;
        }
        for (const f of ['desc_pt', 'desc_en']) {
            if (item[f].length === 0 || item[f].length > maxDescLen) return null;
        }

        let badge = item.badge;
        if (typeof badge !== 'string') badge = 'soon';
        else if (badge !== 'soon' && badge !== 'now') badge = 'soon';

        out.push({ id, title_pt: item.title_pt, title_en: item.title_en,
                   desc_pt: item.desc_pt, desc_en: item.desc_en, badge });
    }
    return out;
}

/* ── fixtures ── */
const big = 'x'.repeat(500);
const validModule = (over = {}) => Object.assign({
    id: 'games', title_pt: 'Jogos', title_en: 'Games',
    desc_pt: 'Biblioteca, minigames e recordes.', desc_en: 'Library, mini-games and high scores.',
    badge: 'soon'
}, over);

const cases = [
    { name: 'feed válido completo (4 módulos)', input: { modules: [validModule(), validModule({id:'web'}), validModule({id:'connect'}), validModule({id:'settings', badge:'now'})] }, expect: 'ok' },
    { name: 'modules vazio', input: { modules: [] }, expect: 'invalid' },
    { name: 'modules com tipo errado (string)', input: { modules: 'games' }, expect: 'invalid' },
    { name: 'sem a chave modules', input: { outro: 1 }, expect: 'invalid' },
    { name: 'raiz nula', input: null, expect: 'invalid' },
    { name: 'raiz array', input: [{ id: 'games' }], expect: 'invalid' },
    { name: 'id fora da whitelist', input: { modules: [validModule({ id: 'evil' })] }, expect: 'invalid' },
    { name: 'id numérico', input: { modules: [validModule({ id: 7 })] }, expect: 'invalid' },
    { name: 'campo ausente (title_en)', input: { modules: [{ id: 'games', title_pt: 'Jogos', desc_pt: 'x', desc_en: 'y' }] }, expect: 'invalid' },
    { name: 'título gigante (500 chars)', input: { modules: [validModule({ title_pt: big })] }, expect: 'invalid' },
    { name: 'descrição vazia', input: { modules: [validModule({ desc_pt: '' })] }, expect: 'invalid' },
    { name: 'badge inválido é normalizado p/ soon', input: { modules: [validModule({ badge: '<script>' })] }, expect: 'ok', badge: 'soon' },
    { name: 'badge ausente vira soon', input: { modules: [{ id: 'games', title_pt: 'J', title_en: 'G', desc_pt: 'd', desc_en: 'd' }] }, expect: 'ok', badge: 'soon' },
    { name: 'item nulo no array', input: { modules: [null] }, expect: 'invalid' },
    { name: 'item não-objeto (string)', input: { modules: ['games'] }, expect: 'invalid' },
];

/* ── executa ── */
let fail = 0;
for (const c of cases) {
    const got = validateModules(c.input);
    const gotKind = got === null ? 'invalid' : 'ok';
    let pass = gotKind === c.expect;
    if (pass && c.badge !== undefined && got[0].badge !== c.badge) pass = false;
    if (!pass) fail++;
    console.log(`  ${pass ? 'PASS' : 'FAIL'}  ${c.name}`);
}

/* ── valida o arquivo publicado ── */
const feedPath = path.join(root, '..', 'prototype', 'feeds', 'modules.json');
const feed = JSON.parse(fs.readFileSync(feedPath, 'utf8'));
const result = validateModules(feed);
if (result === null) { fail++; console.log('  FAIL  feed publicado é inválido'); }
else {
    const ids = result.map(m => m.id).join(',');
    console.log(`  PASS  feed publicado válido (${result.length} módulos: ${ids})`);
    if (result.length !== 4) { fail++; console.log('  FAIL  esperava 4 módulos'); }
}

console.log(fail === 0 ? '\nTODOS OS CASOS PASSARAM' : `\n${fail} FALHA(S)`);
process.exit(fail === 0 ? 0 : 1);
