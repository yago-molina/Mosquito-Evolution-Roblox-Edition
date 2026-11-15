# Fase 2 — iteração 0.2.4: revisão visual do mosquito

## Ponto de partida
O usuário validou 8/8 testes na versão 0.2.3: voo, suavização, obstáculos, altura, sprint, animação das asas e controles mobile no emulador.

## Mudanças
- Modelo anatômico do mosquito em `src/server/MosquitoCharacter.luau` com cabeça, tórax, abdômen segmentado, olhos compostos, antenas, tromba e seis pernas articuladas visualmente.
- Asas elipsoidais com nervuras presas por solda, preservando os dois `WingMotor` existentes.
- Materiais com transparências sutis e detalhes de coloração.
- Sem mudanças nos controles aprovados de PC ou touch.

## Testes obrigatórios no Studio
1. `git pull origin main` e confirme o Rojo antes de Play.
2. Verifique o HUD `v0.2.4` e `Articulacoes das asas encontradas: 2/2`.
3. Olhe o mosquito por diferentes ângulos: as seis pernas precisam estar conectadas ao tórax, as antenas à cabeça e as nervuras devem acompanhar cada asa.
4. Mantenha o mosquito voando parado, depois faça curvas e sprint. As asas não devem se desprender.
5. Repita testes de WASD, Espaço, Ctrl, Shift, stamina, colisão e controles mobile.
6. Confira o Output apenas para erros com prefixo `[MOSQUITO]` ou caminhos de scripts `MosquitoServer`/`MosquitoClient`.

## Limitações
Este é um modelo construído de Parts, não uma malha 3D esculpida. A aparência poderá ser substituída por MeshParts na etapa de arte final. A animação das pernas não foi implementada; os segmentos estão visualmente articulados mas permanecem fixos. A asa continua animada localmente no cliente. A atualização não foi executada pelo assistente no Roblox Studio.
