# Fidelidade ao Mosquito Evolution original

**Referência prioritária:** [Rafael-Massao/mosquito](https://github.com/Rafael-Massao/mosquito), especialmente `script.js`.

A versão Roblox é uma adaptação do jogo existente, não um jogo diferente que reutiliza o nome. A arena de teste e o mosquito que muda só de cor são protótipos temporários; não representam a aparência final.

| Elemento do original | Roblox hoje | Pendência para fidelidade |
|---|---|---|
| Modelo e aparência de 13 estágios | Títulos, cores e escala simples | Recriar forma/estilo de cada estágio observando o modelo original |
| Gotas comuns e douradas, combo | Funcional em arena | Recriar distribuição/visuais, incluir veneno e efeitos |
| 4 upgrades e limites 30 | Regras-base e custos portados | Ajustar escalas/efeitos conforme jogo original |
| Escola 3D e salas | Ausente | Construir escola baseada na geometria do original |
| Humanos, picadas e dificuldade | Ausente | Recriar IA e combate |
| Skins e habilidades | Ausentes | Implementar catálogo e desbloqueios originais |
| Conquistas, segredos e chefe | Ausentes | Portar eventos, puzzles, Sala 3 e boss |
| Save | DataStore v1 em teste | Expandir para todos os campos persistidos no original |

## Regras de trabalho daqui para frente
1. Antes de cada fase, reler as funções/classes relevantes no repositório original.
2. Elaborar comparativo **original → Roblox** com diferenças técnicas explicadas.
3. Construir o conteúdo equivalente, testar no Roblox Studio e só então considerar aceito.
4. Não substituir permanentemente a identidade visual do original por mudanças arbitrárias de cor.
5. Priorizar fidelidade da escola, dos estágios e das interações nas próximas fases. A arte do mosquito atual é temporária.

O original salva em `localStorage`, com campos como `sangue`, `nv`, `skins`, `skin`, `picadas`, `conq`, `salas`, `carteiras`, `mantis` e outros; Roblox utiliza DataStore, por usuário, com expansão gradual de schema.
