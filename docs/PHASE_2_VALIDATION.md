# Relatório de validação — Fase 2 v0.2.4

Fonte: relatório de teste do usuário no Roblox Studio em 15/11/2026.

| Teste | Resultado |
|---|---|
| Modelo apresenta novos detalhes | OK |
| Seis pernas ligadas ao corpo | OK |
| Antenas e tromba posicionadas | OK |
| Duas asas com nervuras animadas | OK |
| Nenhuma peça se desprende | OK |
| WASD/Espaço/Ctrl/Shift/stamina | OK |
| Controles mobile no emulador | OK |
| Sem erros dos scripts Mosquito | OK |

**Resultado:** 8/8 aprovados. Output confirma versão 0.2.4, duas articulações e controle próprio.

**Observação não bloqueante:** plugin externo `cloud_340936329.GUIEditor` falha com `attempt to call a nil value`. Outros plugins geram mensagens de carregamento/asset incompatível. Não são erros dos scripts do projeto.

**Limites da evidência:** não houve execução independente do Studio pelo assistente; controle mobile em aparelho físico e experiência com múltiplos jogadores seguem não testados.

**Decisão:** encerrar a Fase 2 para o protótipo e iniciar a Fase 3 por uma implementação gradual, mantendo o código de voo estável.
