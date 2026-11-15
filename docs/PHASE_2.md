# Fase 2 — Mosquito jogável (protótipo PC)

## Atualização

Na pasta clonada, feche o Play no Studio e rode `git pull` no terminal. Mantenha `rojo serve` executando (ou reinicie-o). Se o Rojo já estiver conectado, ele sincronizará automaticamente.

## Teste esperado

1. Abra a Baseplate conectada ao Rojo e clique **Play**.
2. Seu avatar original ficará invisível, substituído visualmente por um mosquito pequeno.
3. Mova com **WASD**, olhe com o **mouse**, suba com **Espaço**, desça com **Ctrl** e acelere com **Shift**.
4. A barra no HUD mostra stamina. O sprint deve consumir energia e ela deve recuperar quando parar de acelerar.
5. O Output deve informar que o servidor iniciou, o cliente carregou e o voo local está ativo.

## Limites desta entrega

Este é o primeiro protótipo, não a versão final: os controles são desktop; colisão fina e comportamento físico podem precisar de ajuste depois de testes reais; a animação das asas é local e será sincronizada na etapa de polimento multiplayer; os aros são apenas marcadores, sem pontuação. O personagem Roblox é a base de rede por trás da aparência do mosquito.

## Diagnóstico

- Se o avatar ainda aparecer, verifique se `MosquitoCharacter` surgiu em ServerScriptService/MosquitoServer e se o Output aponta erro no servidor.
- Se a câmera não mudar, procure `FlightController` no StarterPlayerScripts/MosquitoClient.
- Se aparecer uma mensagem referente a plugin externo, teste desativá-lo sem alterar os scripts do jogo.
- Se o script não carregar, envie as primeiras linhas vermelhas do Output com o arquivo e número da linha.

**Próxima iteração da Fase 2:** testar e corrigir sensação de voo, colisões, orientação das asas e controles mobile antes de declarar a fase concluída.
