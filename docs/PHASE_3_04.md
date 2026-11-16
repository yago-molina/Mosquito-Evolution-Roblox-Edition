# Fase 3C — correção de loja e voo (v0.3.3)

## Diagnóstico
O usuário validou 10/11 testes de v0.3.2; o único teste reprovado foi: fechar a loja nem sempre reabilita o voo.
A Fase 3C não foi declarada concluída.

## Correções
- A tecla **U** é tratada com `ContextActionService:BindActionAtPriority`, independentemente de `InputBegan` ter sido marcado como processado por uma GUI.
- Botão de loja e tecla U chamam a mesma função `setOpen`, que atualiza visibilidade, mouse e o atributo `MosquitoShopOpen`.
- Tecla **Escape** também fecha o painel (pode abrir menu Roblox dependendo do contexto; U é o método principal).
- `CharacterAdded` força fechamento ao renascer.
- O `FlightController` lê a visibilidade real de `Loja` para decidir se bloqueia movimento, em vez de depender só de um atributo que poderia ficar incorreto.
- Logs explícitos `Loja aberta; voo pausado` e `Loja fechada; voo liberado` permitem diagnosticar o estado.

## Procedimento de teste
1. Parar Play e `git pull origin main`, confirmar Rojo, iniciar Play; HUD v0.3.3.
2. Pressionar U, observar `Loja aberta; voo pausado`; fechar com U e observar `Loja fechada; voo liberado`.
3. Repetir usando o botão `FECHAR [U]`. Seguir com W imediatamente.
4. Repetir mais de 10 vezes com Ctrl, Espaço, W e Shift entre aberturas.
5. Conferir visual de Pernilongo (nível total 3), partículas, asas e HUD; retestar upgrades e coleta.
6. Retestar em Device Emulator: abrir/fechar com toque e mover após fechamento.
7. Reportar somente falhas dos scripts `MosquitoServer`/`MosquitoClient` e mensagens `[MOSQUITO]`; ignorar erros de plugins externos.

## Fase 3D (próxima)
Persistir sangue e os quatro níveis de upgrade com DataStoreService, incluindo tratamento de APIs indisponíveis no Studio, validação dos dados carregados e prevenção de perda de dados. Não ativado ainda nesta versão.
