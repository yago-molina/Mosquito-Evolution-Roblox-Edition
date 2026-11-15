# Fase 2 — iteração 0.2.3
## Escopo
- Movimento com aceleração e frenagem suavizadas.
- Detecção preventiva de colisões com Spherecast (paredes e obstáculos sólidos).
- Limites provisórios de altura.
- Botões experimentais para dispositivos touch: mover, subir, descer e turbo; câmera por arraste no centro.
- HUD responsivo.

## Teste no Studio
1. Pare o jogo. Na pasta do repositório execute `git pull origin main`.
2. Confira o Rojo e clique Play. HUD deve mostrar versão 0.2.3.
3. No PC: verifique movimento horizontal, subida/descida, turbo, stamina e asas.
4. Voe em direção aos obstáculos. Observe se desliza/reduz velocidade, sem atravessar.
5. Teste no **Device Emulator** do Studio com perfil de telefone; botões direcionais devem aparecer.
6. No toque: segure movimento à esquerda, SUBIR/DESCER/TURBO à direita e arraste no meio para olhar.
7. Copie mensagens de erro do Output, se houver.

## Limitações
O teste no Device Emulator não substitui teste em aparelho real. A câmera e a física ainda são prototipais. Spherecast preventivo não é um motor completo de colisão; objetos já sobrepostos e colisões com alta latência precisam validação. A animação das asas ainda é local. Não alteramos economia, progresso ou servidor autoritativo nesta iteração. A versão 0.2.3 foi publicada mas ainda não foi executada pelo assistente dentro do Studio.
