# Fase 3D — DataStore v0.3.4

## Escopo implementado
- Saldo de sangue e níveis de Asas, Tromba, Estômago e Corpo são serializados por UserId.
- Store `MosquitoEvolution_Progress_v1`, esquema `schema=1`.
- Validação rigorosa do save: sangue inteiro 0..1e9; quatro níveis inteiros 0..30.
- `GetAsync` é protegido com `pcall`. Se falhar, sessão fica `Offline` e **não salva**, para não sobrescrever progresso válido.
- Save inválido fica `Invalid`, também não é sobrescrito.
- Compras e coletas ficam bloqueadas enquanto o progresso carrega.
- `UpdateAsync`, escrita serializada por jogador no servidor e sem salvar a cada gota.
- Tentativas a cada 90 segundos, ao sair e no fechamento do servidor.
- HUD: `SALVAMENTO: CARREGANDO / ATIVO / INDISPONÍVEL`.

## Teste seguro no Roblox Studio
1. **Crie uma experiência de teste privada separada** da experiência que pretenda publicar, evitando afetar dados de produção.
2. Publique a experiência de teste. Em **Game Settings > Security**, habilite **Enable Studio Access to API Services** para essa experiência de desenvolvimento.
3. Faça `git pull origin main` com Play parado, sincronize Rojo e entre.
4. Confirme v0.3.4 e `SALVAMENTO: ATIVO`. Um place não publicado ou API bloqueada mostrará `INDISPONÍVEL`, e não tentará salvar.
5. Colete sangue, compre 1 ou 2 upgrades, registre saldo e níveis.
6. Pare e reinicie Play. Saldo, níveis e aparência (calculada do nível total) devem retornar.
7. Output esperado: `[MOSQUITO] Save carregado` e `[MOSQUITO] Save confirmado`.
8. Se quiser simular falha, faça em experiência de teste: desabilite acesso API no Studio. O cliente deve poder jogar em sessão temporária, mas não gravar.
9. Reteste loja U, câmera, voo, asas e toque. Ignore mensagens de plugins externos.

## Limitações e cuidados
- A persistência ainda **não foi validada no Studio pelo assistente**.
- Este é um primeiro save para o protótipo, **não um sistema pronto para público**: falta session locking entre servidores, mais testes de falha de escrita e expansão do schema para skins, missões e conquistas.
- Não teste com dados reais de jogadores antes de endurecer sessões simultâneas.
- No jogo original, o save em `localStorage` abrange também skins, salas, conquistas, picadas e puzzles; esta primeira versão salva somente sangue e níveis.
