# ADR-0004 — Rail custom com foco gerenciado pela cena (não RowList)

**Contexto:** a Home tem 4 módulos fixos; grids nativas (RowList) tratam setas sozinhas e reportam por observeField — feitas pra rails de conteúdo dinâmico.
**Opções:** RowList · rail custom (LayoutGroup de ModuleTiles) com índice de foco na cena.
**Escolha:** rail custom — determinístico, espelha o protótipo web (wrap, índice), sem virtualização necessária pra N=4.
**Consequência:** onKeyEvent da cena é a única fonte de navegação (left/right/OK/options); ring+escala no tile via campo `focused`.
**Reverter quando:** módulo Jogos (Fase 2) renderizar catálogo real — aí RowList virtualizado por exigência de memória (512 MB).
