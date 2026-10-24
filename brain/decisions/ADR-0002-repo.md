# ADR-0002 — Canal vive no mesmo repo (roku/), Pages publica só prototype/

**Contexto:** o repo galaxyos já hospeda protótipo web + docs + skills; o workflow do Pages faz upload apenas de `prototype/`.
**Opções:** repo separado pro canal · subpasta `roku/` no mesmo repo.
**Escolha:** `roku/` no mesmo repo (src/ + toolchain + tests), com `roku/out/` e `node_modules/` no .gitignore.
**Consequência:** um só cérebro (brain/ + docs/ + research) pro web e TV; deploy Pages intacto; zip de sideload gerável a qualquer momento de `roku/src/`.
**Reverter se:** for submeter à Store (aí o canal ganha repo próprio com CI de package/assinatura).
