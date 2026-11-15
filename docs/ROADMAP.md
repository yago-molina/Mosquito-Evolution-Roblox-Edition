# Plano de desenvolvimento

Cada fase só é considerada concluída depois de testes no Roblox Studio.

1. **Fundação** — estrutura Rojo, inicialização, documentação e primeiro teste no Studio.
2. **Mosquito jogável** — modelo, câmera, voo, colisão, sprint e stamina.
3. **Progressão** — sangue, HUD, quatro upgrades e 13 estágios de evolução.
4. **Escola** — mapa em módulos baseado no original, portas e interação.
5. **NPCs e combate** — humanos, picadas, dano, comportamento e dificuldade.
6. **Skins e segredos** — coleção, 17 skins, habilidades e conquistas.
7. **Chefe e multiplayer** — Sala 3, RacketBoss e sincronização para múltiplos jogadores.
8. **Polimento e lançamento** — QA, desempenho, mobile, saves e beta.

Referência original: https://github.com/Rafael-Massao/mosquito

### Regras técnicas

- O servidor valida recursos, upgrades e dano.
- O cliente cuida de câmera, HUD e efeitos locais.
- Nunca armazenar segredos ou dados persistentes exclusivamente no cliente.
- Preferir testes em Baseplate e dispositivos móveis antes de ampliar o mapa.
- O Git guarda scripts e configurações; o lugar Roblox guarda modelos editados no Studio até adotarmos um pipeline de assets.
