# Fase 3C — primeira implementação (v0.3.2)

## Resultado anterior
3B passou 13/13 testes conforme relato do usuário. Um problema adicional fora dos testes: alternar Ctrl/Espaço pode fazer W deixar de responder.

## Bug corrigido: teclado
`FlightController` deixa de armazenar estados de teclado a partir de `InputBegan`/`InputEnded`, pois eventos consumidos pelo CoreGui podem deixar teclas presas ou não registradas. Agora `UserInputService:IsKeyDown` lê o estado físico de cada tecla em cada atualização da física. Os botões mobile continuam utilizando a tabela virtual `keys`. Enquanto a loja estiver aberta, os comandos de voo são desativados via atributo local `MosquitoShopOpen`.

## Transformações visuais
- O servidor calcula o estágio de acordo com `UpgradeTotal`, derivado das quatro melhorias.
- `EvolutionVisual.luau` aplica uma paleta individual para os 13 estágios, baseada nas cores das fases do jogo original.
- Aumenta progressivamente tamanhos das Parts do modelo (até 1,65× nas peças principais) sem mudar o HumanoidRootPart, a câmera ou a configuração dos motores das asas.
- Em mudanças de estágio, emite partículas temporárias e atualiza uma iluminação leve ao redor do mosquito.
- Adicionado um indicador permanente do estágio e nível total no HUD de sangue.
- O modelo é reaplicado ao renascer, sem conceder upgrades no cliente.

## Como testar
1. Pare Play, execute `git pull origin main` e confirme Rojo conectado.
2. HUD deve indicar `v0.3.2`.
3. Faça exatamente o cenário do bug: Espaço, Ctrl, Espaço, Ctrl, depois W. W deve continuar funcionando. Teste combinações simultâneas W+Espaço, W+Ctrl e sem teclas.
4. Abra e feche a loja com U. Movimento deve voltar ao fechar.
5. Junte sangue, compre 3 upgrades no total. A evolução passa de Larva voadora para Pernilongo, com nova cor e partículas.
6. Continue até nível 7 se possível. A cor muda novamente para Caçador noturno.
7. Confira asas animadas, pernas conectadas, câmera, colisão, stamina e controles touch.
8. Teste respawn se disponível: a aparência deve corresponder ao nível total atual.
9. Envie as mensagens `[MOSQUITO]` e erros nos scripts do nosso projeto. Ignore plugins externos.

## Limitações
O crescimento é visual (geometria da raiz física e dos pivôs não cresce); será necessário refinar os modelos de cada estágio em uma fase de arte. Os testes de níveis 100/110/120 dependem da economia ou de ferramenta de teste futura; não foram validados nesta versão. Estado da sessão ainda não é salvo em DataStore.
