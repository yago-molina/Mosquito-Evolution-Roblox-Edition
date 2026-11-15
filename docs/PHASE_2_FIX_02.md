# Fase 2 — correção 0.2.2: asas
## Diagnóstico
O jogador confirmou movimento WASD, subida/descida, sprint e stamina. O único teste de gameplay pendente era a animação das duas asas. Os erros exibidos no Output vêm do plugin `GUIEditor`, não do código do jogo.

## Mudanças
- O `FlightController` registra cada `WingMotor` com sua orientação inicial e lado.
- Substituímos `Motor6D.Transform` por alterações locais no `Motor6D.C0` a cada frame para evitar sobrescritas no ciclo de animações.
- Oscilação aumentada e desacelerada para ficar perceptível.
- Ao parar/respawnar, restauramos o C0 original.
- Mensagem no Output: `[MOSQUITO] Articulacoes das asas encontradas: 2/2`.

## Como testar
1. Pare o Play e rode `git pull origin main` na pasta do projeto.
2. Confirme a sincronização do Rojo e clique em Play.
3. Confira `v0.2.2` no HUD e `Articulacoes das asas encontradas: 2/2` no Output.
4. Pare o mouse, observe o mosquito por alguns segundos; ambas as asas devem subir e descer.
5. Confira também WASD, Espaço, Ctrl, Shift, câmera e stamina.
6. Se mostrar `0/2` ou `1/2`, copie as mensagens do Output.
7. Para testar sem erro de plugin externo, desative temporariamente o `GUIEditor` no gerenciador de plugins.

**Nota:** animação client-side neste protótipo. Sincronização visual multiplayer será tratada em fase posterior. Ainda não foi validada com execução no Studio por este assistente.
