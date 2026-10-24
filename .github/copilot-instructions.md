# Instruções de Desenvolvimento - appAnalise

## Contexto do Projeto

Este é um projeto MATLAB com frontend desenvolvido em App Designer, executado via VS Code integrado 
com MATLAB. O app mantém em `C:\ProgramData\ANATEL\appAnalise` (caso sistema operacional seja Windows) 
um cache dos arquivos de `src/config`. Sempre que algum arquivo na pasta `src/config` for alterado, 
incremente a versão em `src/config/GeneralSettings.json` para que o app atualize o cache.

## Dependências

### SupportPackages

- **Localização local**: `C:\SupportPackages`
- **Tipo**: Repositório MATLAB com funções e utilitários compartilhados
- **Acesso**: Acessível pelo workspace (deve estar no path MATLAB ou importado conforme necessário)

## Arquivos MLAPP vs Exported

### Arquivos .mlapp (Não analisar diretamente)

- **Tipo**: Binários zipados (formato proprietário MATLAB App Designer)
- **Conteúdo**: Metadados de GUI, relacionamentos entre elementos, classe `matlab.apps.AppBase`
- **Acesso**: Não deve ser analisado diretamente neste projeto
- **Exemplo**: `src/winAppAnalise.mlapp`, `src/+auxApp/dockChannels.mlapp`

### Arquivos *_exported.m (Analisar estes)

- **Tipo**: Código MATLAB (.m) legível
- **Origem**: Gerados automaticamente pelo script `deploy/preCompile.m` 
- **Propósito**: Versão exportada e versionável dos .mlapp
- **Quando analisar código**: Sempre usar o arquivo `*_exported.m` correspondente
- **Exemplo**: `src/winAppAnalise_exported.m` (gerado de `src/winAppAnalise.mlapp`)

## Script de Compilação Prévia

### preCompile.m

**Localização**: `deploy/preCompile.m`

**Funcionalidade**:
- `preCompile()` (padrão) ou `preCompile('generateExportedApps', prjInfo, appNames)`: converte .mlapp em .m legível (`*_exported.m`)
- `preCompile('generateMLAPPFromExported', prjInfo, appNames)`: operação inversa, recria o .mlapp a partir do `*_exported.m` (via `m2mlapp`)
- A implementação está em `appEngine.generateExportedApps` e `appEngine.generateMLAPPFromExported` (SupportPackages). `prjInfo` (padrão: `currentProject`) e `appNames` (cellstr com nomes de classe, como `{'winConfig'}`; padrão: todos) são opcionais
- Nos apps auxiliares (`src/+auxApp`), injeta suporte a renderização em containers genéricos. O app principal (`.mlapp` diretamente em `src`) só tem o nome da classe e do construtor alterados (sufixo `_exported`)
- Os `*_exported.m` permitem versionar e editar o código fora do App Designer

**Container Support**: 
- A ferramenta permite renderizar apps em diferentes containers:
  - `uifigure` (figura padrão)
  - `uipanel` (painel dentro de figura existente)
  - `uitab` (aba dentro de tab group)
  - Outros containers conforme necessário

## Fluxo de Desenvolvimento no MATLAB App Designer, editando arquivo `.mlapp`

Abre-se o arquivo `.mlapp` no MATLAB App Designer para iniciar a edição. Após concluir as alterações, deve-se executar o `preCompile()` para gerar os arquivos `*_exported.m` correspondentes.

## Fluxo de Desenvolvimento no VSCode (Copilot), editando arquivo `*_exported.m`

Após editar um `*_exported.m`, o `.mlapp` correspondente **não é atualizado automaticamente**. O usuário deve executar **MANUALMENTE**, no MATLAB:

```matlab
preCompile('generateMLAPPFromExported', currentProject, {'winConfig'}) % lista com os apps indicados (nomes das classes)
preCompile('generateMLAPPFromExported') % todos os apps do projeto
```

**Ao concluir qualquer edição em um `*_exported.m`, lembre o usuário de executar esse comando.** Não o execute por conta própria. Informe também que:
- O app não pode estar aberto no App Designer (ele manteria uma cópia desatualizada).
- O `.mlapp` existente é substituído (metadados são preservados por `m2mlapp`).
- O script `m2mlapp` deve estar no path do MATLAB.

## Estrutura rígida de uma classe do App Designer

O `.mlapp` tem estrutura fixa, e o `m2mlapp` só preserva o que estiver na posição e no formato esperados. Os `*_exported.m` mantêm essa estrutura (exceto pelos trechos descritos em "Regras específicas dos `*_exported.m`").

| # | Bloco (na ordem do arquivo) | Conteúdo | Edição |
|---|---|---|---|
| 1 | `properties (Access = public)` iniciado por `% Properties that correspond to app components` | Elementos da GUI (`UIFigure`, `GridLayout` etc) | **Proibida** |
| 2 a n | Blocos `properties` e `methods` do usuário (`private` ou `public`) | Propriedades e métodos do app | **Livre** |
| n+1 | `methods (Access = private)` iniciado por `% Callbacks that handle component events` | `startupFcn`, `closeFcn` e demais callbacks | Apenas o **corpo** das funções existentes |
| n+2 | `methods (Access = private)` iniciado por `% Component initialization` | `createComponents` | **Bloqueado** |
| n+3 | `methods (Access = public)` iniciado por `% App creation and deletion` | Construtor e `delete` | **Bloqueado** |

### Bloco 1: componentes da GUI (proibido)

- Não edite este bloco por iniciativa própria. No App Designer ele é gerado automaticamente quando um elemento é inserido no canvas.
- Cada propriedade corresponde a um elemento criado em `createComponents` (bloco n+2), e a ordem reflete a hierarquia e o empilhamento (z-order) do App Designer.
- Se o usuário pedir para **incluir, remover ou renomear um elemento da GUI** pelo Copilot, **confirme a operação antes de editar** e sugira fazer isso no próprio App Designer, pois a ordem de empilhamento é facilmente comprometida. Se o usuário mantiver o pedido, faça, mantendo as três pontas consistentes:
  1. A propriedade no bloco 1 (`NomeDoElemento    matlab.ui.control.Tipo`), junto ao pai e coerente com a ordem de criação.
  2. A criação em `createComponents` (`% Create NomeDoElemento` seguido de `app.NomeDoElemento = ui...(app.Pai);` e suas propriedades), na mesma ordem relativa dos irmãos.
  3. Se houver interação, o callback (ver abaixo).

### Blocos 2 a n: código do usuário (livre)

- Aqui podem ser criados livremente propriedades (inclusive `Role`, `Context`, `Container`, `isDocked`, handles etc) e métodos auxiliares, em blocos `properties`/`methods` com qualquer `Access`.
- **Novos métodos auxiliares devem ser criados aqui**, nunca no bloco de callbacks.

### Bloco n+1: callbacks (apenas o corpo das funções)

- Pode-se editar o código **dentro** das funções já existentes (`startupFcn`, `closeFcn`, callbacks).
- **Não crie métodos novos neste bloco, a menos que sejam callbacks.** O `m2mlapp` só preserva a função `startupFcn` e as funções apontadas por um `createCallbackFcn(app, @nome, true)` em `createComponents`. Qualquer outra função neste bloco é **descartada** ao gerar o `.mlapp`.
- Para adicionar um callback a um elemento, use `createCallbackFcn` em `createComponents`, exatamente neste formato (incluindo `true`):

  ```matlab
  app.Tab1Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
  ```

  e crie a função com o mesmo nome no bloco de callbacks, mantendo o formato do App Designer (assinatura `(app, event)` e o código logo em seguida):

  ```matlab
          % Value changed function: Tab1Button
          function onTabNavigatorButtonPushed(app, event)
              % corpo da função
          end
  ```

  Os comentários `% <Evento> function: <Elemento>` são regenerados pelo App Designer, mas mantenha-os coerentes. `startupFcn` pode ter argumentos adicionais (`startupFcn(app, mainApp)`), repassados pelo construtor.
- Renomear um callback exige alterar o nome na função **e** no `createCallbackFcn`. Remover um callback exige remover os dois.

### Blocos n+2 e n+3: `createComponents`, construtor e `delete` (bloqueados)

- São bloqueados no App Designer e não devem ser editados, exceto para criar elementos/callbacks conforme descrito acima (operação que exige confirmação e é desaconselhada).
- No construtor, o `*_exported.m` difere do original; não o altere (ver abaixo).

## Regras específicas dos `*_exported.m`

- **App principal** (`src/*_exported.m`): só o nome da classe e do construtor têm o sufixo `_exported`. Mantenha-os.
- **Apps auxiliares** (`src/+auxApp/*_exported.m`): os trechos abaixo são reconhecidos por texto na conversão inversa. Não os altere:
  - `function createComponents(app, Container)` e o ramo `if isempty(Container) ... else ... end` (exceto as linhas `app.UIFigure...` dentro de `if isempty(Container)`, que podem ser editadas e são restauradas em `createComponents(app)`).
  - `app.GridLayout = uigridlayout(app.Container);`.
  - O construtor `function app = <nome>_exported(Container, varargin)` e o `delete`, que são **substituídos** pelo padrão do App Designer na conversão inversa: qualquer edição neles é perdida.
  - A `UIFigure` deve ter como único filho direto o `GridLayout`; as propriedades `Container` e `isDocked` e a função `startupFcn` devem existir.
- A propriedade `Role` (`'mainApp'`, `'secondaryApp'` ou `'secondaryDockApp'`) define os requisitos do app, validados por `appEngine.checkRole` quando `startupFcn` chama `appEngine.boot(app, app.Role, ...)`. Não remova propriedades ou métodos exigidos para o papel do app.

## Padrão de Nomenclatura

- `.mlapp`: `nomeApp.mlapp`
- `.m exportado`: `nomeApp_exported.m`

## Estrutura de Packages

O projeto usa packages MATLAB (pastas `+`) em `src`:

- `+auxApp`: apps auxiliares (`.mlapp` e `*_exported.m`)
- `+class`: constantes (`Constants`) e bibliotecas de apoio (`ChannelLib`, `EMSatDataHubLib`)
- `+model`: modelos de dados do projeto (`Project`, `ProjectBase`, `SpecData`, `Band`, `MetaData`, `UserData`)
- `+plot`: criação e interação com gráficos
- `+reportLibConnection`: integração com a biblioteca de geração de relatórios
- `+util`: utilitários (leitura/gravação de arquivos, filtros de tabela, geradores de texto HTML etc)

Os packages `appEngine` e `ui` vêm de SupportPackages.

## Modelo de Escrita de Código

**Convenções de nomenclatura:**
- **PascalCase**: nomes de elementos da GUI, nomes de classes
- **camelCase**: nomes de funções, métodos e variáveis locais
- **SCREAMING_CASE**: constantes

Os nomes devem ser semanticamente significativos e seguir as convenções de nomenclatura descritas acima, com a observação que callbacks de elementos da GUI devem começar com `on` seguido do nome do elemento e do tipo de evento, por exemplo: `onTabNavigatorButtonPushed`.

**Separador de funções**

Antes de cada função, insira uma linha de comentário para facilitar a visualização, por exemplo:

```matlab
  %-----------------------------------------------------------------%
  function html = receiverBadge(label)
    % ...
  end

  %-----------------------------------------------------------------%
  function icon = monitoringTypeIcon(specData)
    % ...
  end
```

**Chamar métodos de uma classe**

Use a notação `methodName(obj, ...)` ao invés de `obj.methodName(...)` para chamar métodos de instâncias de classes.

Adote este padrão em todo o código MATLAB do projeto.

**Nota**: Este arquivo foi criado para orientar o desenvolvimento e análise de código neste projeto.