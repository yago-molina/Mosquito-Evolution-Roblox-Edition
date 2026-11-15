# Correção Fase 2.1 — controlador travado

## Causa
O FlightController aguardava `PlayerScripts:WaitForChild("PlayerModule")` sem timeout. Como o módulo não estava presente, o script parava antes de conectar teclado, física, stamina e animação das asas.

## Alterações
- `PlayerModule` passou a ser opcional, consultado com `FindFirstChild`.
- A ausência do módulo não interrompe a execução do controlador.
- O script procura os `WingMotor` no personagem inteiro, porque são filhos de `HumanoidRootPart`.
- O raycast da câmera ignora o próprio personagem.
- A versão passa a `0.2.1`.

## Teste no Roblox Studio
1. Pare o Play.
2. Na pasta clonada do projeto, execute `git pull origin main`.
3. Certifique-se de que o Rojo está conectado e clique Play.
4. Confira o Output: `[MOSQUITO] PlayerModule ausente: controle de voo independente ativado.` e `[MOSQUITO] Voo local ativo...`.
5. Teste WASD, Espaço, Ctrl e Shift. Observe a barra de stamina e as asas.
6. Se ainda ficar parado, copie as primeiras mensagens vermelhas do Output e informe se `[MOSQUITO] Voo local ativo` aparece.

Esta correção não foi executada em Roblox Studio pelo assistente; é necessário testar no ambiente do jogador.
