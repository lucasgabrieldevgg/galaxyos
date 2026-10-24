# ADR-0001 — Stack: BrightScript + SceneGraph (avaliar RSG 2.0 no beta)

**Contexto:** Fase 1 precisa de stack certificável e documentada hoje; RSG 2.0 (TypeScript, MIT) entra em beta público 29/10/2026 sem data pra submissão à Store.
**Opções:** BrightScript+SceneGraph · RSG 2.0 beta · híbrido.
**Escolha:** BrightScript + SceneGraph + tooling Node (brighterscript/roku-deploy). No dia 29/10, prototipar UMA tela no RSG 2.0 e medir esforço antes de qualquer migração.
**Consequência:** caminho chato e provado; migração futura é opcional e medida.
**Reverter se:** RSG 2.0 abrir submissão à Store e o protótipo de tela custar menos que o equivalente em BrightScript.
