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
2. Upload do zip: **`galaxyos-roku-channel-v0.1.zip`** (manifest na raiz) — compressão `squashfs`.
3. O canal abre direto e fica na fileira de baixo da Home da TV.

**Opção B — CLI (iterativo, pra mudanças diárias):**
```bash
cd roku
npm install
ROKU_DEV_TARGET=<ip-da-tv> ROKU_DEV_PASSWORD=<senha> npm run deploy
```

**Regenerar o zip a qualquer momento:**
```bash
cd roku/src && zip -r ../../galaxyos-channel.zip manifest source components images
```

## 3. Verificar (rung 4)

- [ ] Splash Deep Space → Home com nebulosa, "GalaxyOS" e relógio certos
- [ ] **← →** movem o foco (ring ciano + escala) com wrap; painel de detalhe acompanha
- [ ] **OK** em Jogos/Web Hub/Connect → status "Módulo previsto para a próxima fase"; em Configurações → troca PT/EN
- [ ] **\*** (options) troca o idioma; idioma **persiste** após sair e voltar
- [ ] **Back** sai do canal sem travar
- [ ] Console limpo: `telnet <ip-da-tv> 8085` → linhas `[App]`/`[Home]`/`[Feed]` sem erros

## 4. Adversarial (rung 5, no sofá)

- [ ] Arrow-mash (setas rápidas sem parar) — foco nunca se perde
- [ ] Back-spam — sai limpo
- [ ] TV **sem cabo/rede** ao abrir → módulos locais + aviso "Sem conexão"
- [ ] Esperar virar a hora → relógio e saudação atualizam sozinhos
- [ ] Screenshot no plug-in (Utilities) — sairá 1280×720 (limite do device)

## 5. Depois do smoke

Preencher `brain/device-info.md` (IP, versão OS, datas) e marcar os rungs em `brain/tasks.md`. Se algo falhar: anotar a linha de erro do telnet — é o insumo da próxima sessão.
