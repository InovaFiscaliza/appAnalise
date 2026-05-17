# Instruções de Desenvolvimento - appAnalise

## Contexto do Projeto

Este é um projeto MATLAB com frontend desenvolvido em App Designer, executado via VS Code integrado com MATLAB.

## Dependências

### SupportPackages
- **Localização local**: `C:\SupportPackages`
- **Tipo**: Repositório MATLAB com funções e utilitários compartilhados
- **Acesso**: Acessível pelo workspace (deve estar no path MATLAB ou importado conforme necessário)

## Arquivos MLAPP vs Exported

### Arquivos .MLAPP (Não analisar diretamente)
- **Tipo**: Binários zipados (formato proprietário MATLAB App Designer)
- **Conteúdo**: Metadados de GUI, relacionamentos entre elementos, classe `matlab.apps.AppBase`
- **Acesso**: Não deve ser analisado diretamente neste projeto
- **Exemplo**: `src/winAppAnalise.mlapp`, `src/+auxApp/dockChannels.mlapp`

### Arquivos *_exported.M (Analisar estes)
- **Tipo**: Código MATLAB (.M) legível
- **Origem**: Gerados automaticamente pelo script `preCompile.m` 
- **Propósito**: Versão exportada e versionável dos .MLAPP
- **Quando analisar código**: Sempre usar o arquivo `..._exported.m` correspondente
- **Exemplo**: `src/winAppAnalise_exported.m` (gerado de `src/winAppAnalise.mlapp`)

## Script de Compilação Prévia

### preCompile.m
**Localização**: `deploy/preCompile.m`

**Funcionalidade**:
- Converte .MLAPP em .M legível (`*_exported.m`)
- Injeta suporte a renderização em containers genéricos
- Mantém versionamento do código

**Container Support**: 
- A ferramenta permite renderizar apps em diferentes containers:
  - `uifigure` (figura padrão)
  - `uipanel` (painel dentro de figura existente)
  - `uitab` (aba dentro de tab group)
  - Outros containers conforme necessário

## Fluxo de Desenvolvimento

1. **Editar no App Designer**: Modifique o arquivo `.MLAPP` normalmente no MATLAB App Designer
2. **Executar preCompile**: Rode `deploy/preCompile.m` após alterações
3. **Analisar/Versionar**: Trabalhe com os arquivos `*_exported.m` 
4. **Controle de Mudanças**: Os `.M` exportados são versionáveis (ao contrário dos binários `.MLAPP`)

## Padrão de Nomenclatura

- `.MLAPP`: `nomeApp.mlapp`
- `.M exportado`: `nomeApp_exported.m`

## Estrutura de Packages

O projeto usa packages MATLAB (pastas `+`):

**Nota**: Este arquivo foi criado para orientar o desenvolvimento e análise de código neste projeto.

## Modelo de Escrita de Código

**Convenções de nomenclatura:**

- **PascalCase**: nomes de elementos da GUI, nomes de classes
- **camelCase**: nomes de funções, métodos e variáveis locais
- **SCREAMING_CASE**: constantes

**Separador de funções:**

Antes de cada função, insira uma linha de comentário para facilitar a visualização, por exemplo:

  %-----------------------------------------------------------------%
  function html = receiverBadge(label)
    % ...
  end

  %-----------------------------------------------------------------%
  function icon = monitoringTypeIcon(specData)
    % ...
  end

Adote este padrão em todo o código MATLAB do projeto.
