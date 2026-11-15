# Aula 01 — preparação do ambiente (Windows)

## 1. Ferramentas

- **Roblox Studio**: https://create.roblox.com/
- **Visual Studio Code**: https://code.visualstudio.com/
- **Rojo CLI e plugin Studio**: https://rojo.space/docs/v7/getting-started/installation/
- **Git**: https://git-scm.com/downloads

No VS Code, recomendamos a extensão **Luau Language Server** para autocompletar e avisos.

## 2. Baixe o código

Abra PowerShell em uma pasta de projetos:

```powershell
git clone https://github.com/yago-molina/Mosquito-Evolution-Roblox-Edition.git
cd Mosquito-Evolution-Roblox-Edition
```

## 3. Instale o Rojo

Instale o executável **Rojo 7** pelo instalador/gerenciador indicado na documentação oficial e instale também o **plugin Rojo** no Roblox Studio. Execute `rojo --version` no PowerShell para conferir se o comando está no PATH.

## 4. Inicialize a sincronização

No terminal, na raiz do repositório:

```powershell
rojo serve
```

Mantenha essa janela aberta enquanto trabalha. O projeto usa a porta 34872.

## 5. Conecte o Roblox Studio

1. Abra o **Roblox Studio** e crie uma experiência **Baseplate** nova.
2. Ative as janelas **Explorer**, **Properties** e **Output** pelo menu **View/Exibir** (o posicionamento pode variar conforme a interface).
3. Abra o plugin **Rojo** e escolha **Connect** com o servidor local na porta **34872**.
4. Confirme a sincronização. Verifique se apareceram os objetos abaixo:

```text
ReplicatedStorage
  MosquitoShared
    GameConfig (ModuleScript)
ServerScriptService
  MosquitoServer
    Bootstrap (Script)
StarterPlayer
  StarterPlayerScripts
    MosquitoClient
      Bootstrap (LocalScript)
```

5. Clique em **Play**.
6. Você deverá ver uma plataforma escura, um mosquito demonstrativo e o HUD vermelho **MOSQUITO EVOLUTION**. Seu personagem ainda será o avatar padrão — é intencional nesta fase.
7. Abra **Output** e procure:

```text
[MOSQUITO] Servidor iniciado ...
[MOSQUITO] Cliente iniciado ...
```

## 6. Salve sua experiência

No Studio, use **File > Save to File** para guardar uma cópia local do lugar e **Publish to Roblox** quando desejar criar a experiência no Roblox. Arquivos `.rbxl` locais são ignorados pelo Git deste projeto. A cena de demonstração é recriada durante a execução (não é o mapa definitivo).

## Diagnóstico de erros

| Sintoma | O que verificar |
|---|---|
| `rojo` não reconhecido | Instalou o CLI e reiniciou o terminal? `rojo --version` funciona? |
| Plugin não conecta | `rojo serve` ainda está executando na pasta certa? Porta 34872? |
| Scripts ausentes no Explorer | Projeto sincronizado? Os arquivos `.server.luau` e `.client.luau` foram baixados? |
| HUD não aparece | Você clicou em **Play**, não apenas executou um script? Leia o **Output**. |
| Plataforma não aparece | Veja se há erro do `Bootstrap` do servidor no **Output**. |

## Próxima aula

Fase 2: substituir o avatar por um mosquito controlável com câmera, seis direções de voo e stamina. Não confundir o mosquito estático de demonstração com a versão final.
