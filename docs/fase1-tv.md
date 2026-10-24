# Fase 1 — colocar o GalaxyOS na AOC 43S5155

> Guia do rung 4 (smoke) e 5 (adversarial). Tudo verificado nas docs oficiais em 24/10/2026 (`docs/research/fase1-notes.md`).

## 1. Ativar o Developer Mode (uma vez)

1. Na TV: **Home** ×3, **Up** ×2, **Right, Left, Right, Left, Right** (remote padrão).
2. Anote a **URL** que aparece na tela (ex.: `http://192.168.0.42`).
3. Ative o **Development Application Installer**, aceite o Developer Tools License Agreement e crie a **senha** de dev (case-sensitive; guarde no gerenciador de senhas, nunca no git).
4. A TV reinicia já em dev mode.

## 2. Instalar o canal (PC na mesma rede)

**Opção A — navegador (universal):**
1. Abra a URL da TV, login `rokudev` + senha.
2. Upload do zip: **`galaxyos-roku-channel-v0.2.zip`** (manifest na raiz) — compressão `squashfs`.
3. O canal abre direto e fica na fileira de baixo da Home da TV.

**Opção B — CLI (iterativo, pra mudanças diárias):**
```bash
cd roku
npm install
ROKU_DEV_TARGET=<ip-da-tv> ROKU_DEV_PASSWORD=<senha> npm run deploy
```

> Instalar de novo **não exige desinstalar nada**: o instalador dev
> substitui o canal no mesmo lugar. O canal fica na TV até o dev mode
> ser desativado. Um `npm run deploy` leva ~10 s.

**Regenerar o zip a qualquer momento:**
```bash
cd roku/src && zip -r ../../galaxyos-channel.zip manifest source components images
```

## 3. Verificar (rung 4)

- [ ] Splash Deep Space → Home com nebulosa, "GalaxyOS" e relógio certos
- [ ] **← →** movem o foco (ring ciano + escala) com wrap; painel de detalhe acompanha
- [ ] **OK** em Jogos/Web Hub/Connect → status "Módulo previsto para a próxima fase"; em Configurações → "Buscando atualizações..." e depois "Você está na versão mais recente."
- [ ] Foco em Configurações → status mostra "GalaxyOS 0.2 · Conteúdo v2 · 2026-10-24"
- [ ] **\*** (options) troca o idioma; idioma **persiste** após sair e voltar
- [ ] **Back** sai do canal sem travar
- [ ] Console limpo: `telnet <ip-da-tv> 8085` → linhas `[App]`/`[Home]`/`[Feed]` sem erros

## 4. Adversarial (rung 5, no sofá)

- [ ] Arrow-mash (setas rápidas sem parar) — foco nunca se perde
- [ ] Back-spam — sai limpo
- [ ] TV **sem cabo/rede** ao abrir → módulos locais + aviso "Sem conexão"
- [ ] Com o canal aberto, rede volta → próximo ciclo (ou OK em Configurações) recupera o feed sem sair
- [ ] Esperar virar a hora → relógio e saudação atualizam sozinhos
- [ ] Screenshot no plug-in (Utilities) — sairá 1280×720 (limite do device)

## 5. Atualizar o GalaxyOS depois de instalado

O GalaxyOS tem **3 camadas de atualização** (detalhes em `brain/decisions/ADR-0006-updates.md`):

| O quê mudou | Como atualiza | Reinstala? |
|---|---|---|
| **Conteúdo** (módulos, jogos, links — `prototype/feeds/*.json` no GitHub) | Sozinho: re-checa a cada 15 min com o canal aberto (ou **OK em Configurações** para forçar agora) | **Não** |
| **Código** (`.brs`/`.xml` do canal) | 1 comando no PC: `npm run deploy` (~10 s, substitui in-place) | **Não** |
| **Canal publicado** (futuro, na Roku Store) | A Roku empurra para todos os usuários automaticamente | — |

**Teste do update de conteúdo no sofá:** edite `version` no `feeds/modules.json`
(2 → 3) + push no GitHub, deixe o canal aberto e espere até 15 min (ou
force com **OK** em Configurações) → toast "Conteúdo atualizado" e o rail
re-renderiza, tudo sem sair do canal.

## 6. Depois do smoke

Preencher `brain/device-info.md` (IP, versão OS, datas) e marcar os rungs em `brain/tasks.md`. Se algo falhar: anotar a linha de erro do telnet — é o insumo da próxima sessão.
