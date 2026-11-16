# Mosquito Evolution — Roblox Edition

Adaptação em Roblox/Luau do jogo [Mosquito Evolution original](https://github.com/Rafael-Massao/mosquito).

## Estado

**Fase 3D em desenvolvimento (v0.3.4).** Fase 3C aprovada em testes no Roblox Studio. Salvar progresso com DataStore ainda precisa ser validado. A prioridade é a [fidelidade ao jogo original](docs/ORIGINAL_FIDELITY.md); o cenário de testes e os modelos atuais são temporários.

## Início rápido

1. Instale Roblox Studio, VS Code e Rojo 7 (CLI + plugin Studio).
2. Clone este repositório.
3. Na pasta do projeto, execute `rojo serve`.
4. Abra um projeto Baseplate no Roblox Studio e conecte o plugin Rojo à porta 34872.
5. Clique **Play**. O servidor cria a área de testes e substitui visualmente o avatar por um mosquito controlável.

Leia [docs/SETUP.md](docs/SETUP.md) para instruções completas. 

## Desenvolvimento

- `src/server` → ServerScriptService (autoridade do jogo e mundo)
- `src/client` → StarterPlayerScripts (interface e controles locais)
- `src/shared` → ReplicatedStorage/MosquitoShared (configurações compartilhadas)

O Rojo gerencia o código. **Não deixe cenários importantes apenas nos scripts de bootstrap:** objetos de cenário criados diretamente no Studio devem ser salvos/publicados no arquivo do lugar Roblox.

## Referência e direitos

Esta é uma reimplementação educacional; personagens, gráficos e sons de terceiros exigem avaliação de direitos antes da publicação.
