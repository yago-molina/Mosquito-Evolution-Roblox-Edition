# Fase 3 — Plano técnico: sangue, upgrades e evolução

## Marco anterior aprovado
- Versão de base: **0.2.4**
- O usuário validou 8/8 verificações da aparência, conexão das partes, asas, voo, stamina e controle touch no emulador.
- Output sem erros dos scripts `MosquitoServer`/`MosquitoClient`; o plugin externo `GUIEditor` ainda exibe erros. Desativar o plugin no Studio, não modificar o jogo por causa dele.
- Pendente: validação em smartphone físico e sincronização visual multiplayer.

## Referência do jogo original
Fonte: `Rafael-Massao/mosquito/script.js` no GitHub.
- 13 estágios, do nível total 0 (Larva voadora) ao 120 (Soberano do sangue eterno).
- 4 upgrades, nível máximo 30 cada: asas (12), tromba (15), estômago (20), corpo (18).
- **Custo original:** `floor(base * 1.3 ^ nivelAtual)`.
- **Nível de evolução original:** soma dos níveis dos quatro upgrades (0..120). Não confundir com experiência independente.
- Gotas rendem sangue; há multiplicadores de combo e bônus de estômago.
- Interações com humanos e venenos ainda NÃO pertencem ao primeiro incremento da Fase 3.

## Design da implementação — ordem

### 3A. Primeira fatia vertical: coletar sangue
1. `BloodService` no servidor: pontos de surgimento, reaparecimento, validação de proximidade e concessão de sangue.
2. `ProgressionService` no servidor: estado de sessão por jogador e envio de atualizações para cliente via RemoteEvent.
3. Gotas visuais na área de testes, com feedback de coleta e HUD.
4. Garantir que o cliente não possa escolher quantidade de sangue.

**Aceite:** tocar uma gota próxima incrementa sangue uma vez, desaparece e reaparece; um segundo jogador não duplica a recompensa; tentativas remotas inválidas não dão sangue.

### 3B. Quatro upgrades
1. Configuração compartilhada com custo base e taxa 1,3.
2. Servidor valida dinheiro suficiente, nível abaixo de 30 e chave conhecida.
3. Dedução de sangue, aumento do nível e envio do novo estado.
4. HUD com botões e custos.
5. Aplicar atributos ao voo: Asas — velocidade; Tromba — alcance; Estômago — rendimento; Corpo — stamina. Documentar fórmulas utilizadas e comparar com jogo original.

**Aceite:** compra correta, insuficiência de sangue rejeitada, nível máximo respeitado, tentativas simultâneas não gastam incorretamente.

### 3C. Evoluções
1. Calcular estágio pela soma dos quatro upgrades, usando `GameConfig.STAGES`.
2. Transição visual, efeitos, cores e aviso de evolução.
3. Crescimento progressivo compatível com a câmera e colisão.

**Aceite:** estágio muda nos limites 3, 7, 12 etc., último estágio 120, sem queda do FPS quando evoluir.

### 3D. Persistência
1. `DataStoreService` no servidor, habilitado para testes no Studio quando apropriado.
2. `UpdateAsync`/tratamento de falhas, limite de operações, carregamento seguro e salvar na saída.
3. Versão de esquema, verificação dos dados carregados e fallbacks seguros.
4. Evitar gravar a cada gota; persistir em intervalos e eventos relevantes.

**Aceite:** progresso restaura após reconexão sem corrupção; falhas de serviço são tratadas sem apagar dados válidos.

## Diagrama de responsabilidade
```text
Gota / Trigger no Workspace
  -> BloodService (servidor valida)
  -> ProgressionService (saldo por jogador)
  -> RemoteEvent (cliente atualiza HUD)

Botão Upgrade (cliente)
  -> RemoteEvent com id do upgrade
  -> ProgressionService (servidor checa custo, nível e saldo)
  -> RemoteEvent com estado final
  -> Modelo / voo recebem atributos permitidos
```

## Regra de projeto
Fase 2 está concluída por evidência do usuário, não por teste automatizado no Studio feito pelo assistente. NÃO remover nem substituir o voo aprovado para criar a economia. Fase 3 ainda está em planejamento; a mecânica de sangue não foi implementada neste commit.
