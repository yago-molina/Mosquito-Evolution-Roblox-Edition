# Fase 3B — upgrades v0.3.1

## Funcionalidades
- Loja de quatro upgrades: Asas, Tromba, Estômago, Corpo.
- Cliente envia apenas o ID ao `RemoteEvent MosquitoRemotes/BuyUpgrade`.
- Servidor checa se o upgrade existe, dinheiro disponível e nível abaixo de 30; desconta e avança sem yield entre validação e compra.
- Intervalo mínimo de 0,15 s entre solicitações por jogador.
- Custo igual ao original: `floor(base * 1.3 ^ nível)`.
- Saldo e níveis são `Attributes` replicados do servidor; a loja é apenas interface.
- Evolução textual de acordo com a soma dos níveis, sem transformação visual (reservada à Fase 3C).

## Efeitos testáveis
- **Asas:** velocidade normal +1,5 studs/s por nível, turbo +2,2 studs/s por nível. Adaptação do conceito original às velocidades do Roblox.
- **Tromba:** raio de coleta começa em 2 studs e cresce +0,25 por nível.
- **Estômago:** cada gota vale `1 + 2 × nível`, antes dos bônus de dourada/combos; mesma progressão-base do original.
- **Corpo:** stamina máxima `100 + 15 × nível`, recuperação por segundo `19 + 4 × nível`. Progressão-base de stamina igual ao original, com 19 de regeneração-base para compatibilidade com voo Roblox existente.

## Teste no Studio
1. Pare Play. `git pull origin main` e sincronize Rojo.
2. Verifique HUD `v0.3.1`, coleta 3A e log `Loja inicializada`.
3. No PC, pressione **U** para abrir a loja e liberar cursor, clique nas opções ou use 1,2,3,4 com a loja aberta. Pressione U para fechar.
4. No touch, toque **UPGRADES**, depois os botões na loja.
5. Confira custos iniciais 12/15/20/18 e nova tabela depois da primeira compra (ex.: Asas 12 -> 15).
6. Com sangue menor que o custo, a compra é recusada e não reduz o saldo.
7. Compre Asas e compare velocidade, Corpo e verifique stamina, Tromba e alcance, Estômago e rendimento.
8. Compre quaisquer três níveis, confirme o título **Pernilongo** no painel.
9. Reteste asas, câmera, colisões, botões de toque e coleta.
10. Se ocorrer falha, compartilhe linhas do Output dos scripts Mosquito. Ignoramos erros de plugins externos.

## Notas
- Estado ainda é apenas da sessão. Ao encerrar Play, sangue e upgrades recomeçam em zero; DataStore vem depois.
- Saldo e upgrades não são confiados ao cliente.
- Esta implementação foi publicada no GitHub e requer teste em Roblox Studio.
