# Fase 3A — coleta de sangue, v0.3.0

## Implementado
- `BloodService`: cria 22 gotas em posições fixas na arena de teste, com 3 douradas.
- Coleta por proximidade de **2 studs**, validada no servidor a cada ~0,12 s.
- A gota só pode ser coletada uma vez, fica invisível e reaparece após 6 segundos.
- `ProgressionService`: saldo **por jogador**, combo de até 5 em uma janela de 4 segundos, recompensa comum de 1×combo e dourada de 5×combo.
- Atributos replicados do servidor para o jogador: `Blood`, `BloodCombo` e `LastBloodGain`.
- HUD cliente mostrando sangue, combo e último ganho.
- Sem economia no cliente, sem RemoteEvent que conceda sangue, sem DataStore nesta etapa.

## Guia de teste
1. Pare o Play no Studio e execute `git pull origin main`. Confira a sincronização do Rojo.
2. Clique Play: o HUD deve indicar versão `0.3.0` e mostrar `SANGUE 0`.
3. Voe na direção de uma esfera vermelha. Quando se aproximar, ela deve desaparecer e o contador aumentar.
4. Colete mais gotas em até quatro segundos e verifique o multiplicador de combo.
5. Procure uma esfera dourada `5x` e confira seu bônus, multiplicado pelo combo.
6. Aguarde seis segundos e confira se uma gota coletada reaparece.
7. No modo de teste com dois jogadores, observe que uma mesma gota só dá sangue a um jogador.
8. Confirme que o voo da Fase 2, as asas, a stamina e os controles touch seguem funcionando.
9. Envie apenas mensagens com prefixo `[MOSQUITO]` e erros dos scripts `MosquitoServer`/`MosquitoClient`; erros de plugins externos são ignorados.

## Aprendizado
O servidor detecta a proximidade usando `HumanoidRootPart`. Ele chama `ProgressionService.grantDrop`, que atualiza os `Attributes` do `Player`. Esses atributos replicam automaticamente e o cliente escuta `GetAttributeChangedSignal` para atualizar o HUD. Não usamos RemoteEvents para coletar gotas, pois o cliente não precisa pedir recompensas.

## Limitações
- Gotas e valores reiniciam a cada sessão; a persistência virá na Fase 3D.
- Ainda não existem upgrades nem alteração do estágio; serão adicionados nas fases 3B e 3C.
- Gotas possuem posições temporárias e estáticas até existir o mapa da escola.
- Efeitos de partículas e variedade de veneno ainda não estão implementados.
- Ainda não testado pelo assistente no Roblox Studio: requer validação do usuário.
