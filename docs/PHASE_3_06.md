# Fase 3D — diagnóstico e correção v0.3.5

## Resultado da v0.3.4
- Usuário aprovou 6 de 8 verificações, mas **sangue e upgrades não foram restaurados**.
- Relatou "salvamento indisponível".
- Não anexou as linhas com `[MOSQUITO][SAVE]` do teste; a causa exata de leitura não pode ser confirmada apenas com o relato.
- Evitar considerar "SAVE: ATIVO" uma prova de que os valores foram gravados.

## Correções desta versão
- A gravação `UpdateAsync` só é declarada confirmada após retornar um registro válido **com exatamente o sangue e níveis solicitados**.
- Cancelamento de transformação (`nil`) não é mais interpretado como sucesso.
- Logs explícitos de GameId/PlaceId/Studio, resultado GetAsync, conteúdo restaurado, falha de gravação e confirmação.
- HUD distingue erro de gravação, leitura em andamento e modo offline.
- O save continua bloqueado se leitura falhar ou registro anterior for inválido.
- Quando uma gravação falha, uma futura tentativa periódica continua autorizada sem permitir substituir registro inválido.

## Teste seguro com duas sessões
1. **Somente numa experiência de desenvolvimento privada publicada**. Rojo sincronizado após `git pull origin main`.
2. Habilite `Enable Studio Access to API Services` nas configurações de segurança da experiência de teste. O nome da opção pode mudar com atualizações do Studio.
3. Clique Play e espere `[MOSQUITO][SAVE] Leitura OK`, verificando se o GameId e PlaceId são os mesmos nas duas sessões.
4. Faça 2-3 compras e anote os números exatos: sangue, Asas, Tromba, Estômago, Corpo.
5. Pare Play e **verifique no Output anterior ao Stop** a mensagem `[MOSQUITO][SAVE] GRAVACAO CONFIRMADA`. Se ela não aparecer, não conclua que foi salvo; tente deixar uma sessão aberta por pelo menos um ciclo automático de 90s.
6. Inicie Play novamente **na mesma experiência**. Envie a linha `Leitura OK: sangue=... niveis=...` ou aviso `GetAsync falhou`.
7. Confira se os quatro atributos correspondem ao registro e se a aparência é coerente com a soma dos níveis.
8. Desative o acesso API somente para simular falha em ambiente de desenvolvimento: deve aparecer `SAVE: OFFLINE / NÃO SALVA`, e nenhuma gravação será tentada.

## Interpretação dos estados
- `SAVE: LEITURA OK / ATIVO` = leu a API. **Ainda não significa gravação confirmada**.
- `[MOSQUITO][SAVE] GRAVACAO CONFIRMADA` = UpdateAsync retornou valores validados.
- `SAVE: FALHA DE GRAVAÇÃO` = UpdateAsync falhou; dados daquela sessão podem não persistir.
- `SAVE: OFFLINE / NÃO SALVA` = leitura indisponível, place não publicado ou API negada. Progresso desta sessão é temporário.
- Plugin `GUIEditor` e outros plugins do Studio não são parte deste diagnóstico.

## Próxima fase de fidelidade
Reproduzir a escola do jogo original e os modelos específicos de evolução com base em `Rafael-Massao/mosquito/script.js`. A arena e a transformação por cores são protótipos, não arte final.

## Limites
Não testado pelo assistente em Roblox Studio. A solução ainda não implementa session locking entre servidores, exigido antes de publicar para jogadores reais.
