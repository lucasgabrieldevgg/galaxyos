# ADR-0005 — Feed é input não confiável: whitelist + fallback offline

**Contexto:** o JSON do "Hub v0" é servido por um host que pode ser alterado (ou atacado); a UI não pode renderizar qualquer coisa que chegar.
**Opções:** confiar no feed (é "meu" host) · validar tipo/tamanho/forma + whitelist de ids + fallback offline embutido.
**Escolha:** validação completa em função pura (`source/feed-validate.brs`): raiz AA, array 1..8, ids whitelist {games,web,connect,settings}, títulos ≤80, descs ≤160, badge normalizado; falha → módulos locais + aviso "sem conexão".
**Consequência:** feed hostil rejeitado inteiro (fail-closed); TV sempre tem UI útil; contrato testado em fixtures (16/16).
**Reverter se:** — (regra de segurança, não há reversão prevista; extensão de whitelist só com nova entrada no validador + testes).
