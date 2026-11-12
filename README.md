# appAnalise  [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/InovaFiscaliza/appAnalise)


O appAnalise é uma ferramenta de pós-processamento de dados gerados em monitorações do espectro de radiofrequências conduzidas pelos principais receptores e analisadores de espectro disponíveis na Agência. 
- O app faz a leitura de arquivos gerados por diversas ferramentas, incluindo o Logger (da CRFS), Argus (da Rohde & Schwarz), CellSpectrum (da CellPlan) e appColeta.
- O app possibilita a automação dos processos de detecção e classificação de emissões, geração de relatórios e o upload dos relatórios no SEI por meio de API do eFiscaliza.

PLAYBACK
<img width="1920" height="1080" alt="Screenshot 2026-10-01 060525" src="https://github.com/user-attachments/assets/efdbfc4b-9b1a-4cb2-bdba-f8889878c02c" />

DRIVE-TEST
<img width="1920" height="1080" alt="Screenshot 2026-10-01 060744" src="https://github.com/user-attachments/assets/72374ca6-eec7-4cd3-bcca-4574837339b9" />

BASE DE DADOS DE ESTAÇÕES DE TELECOMUNICAÇÕES
<img width="1920" height="1080" alt="Screenshot 2026-10-01 061110" src="https://github.com/user-attachments/assets/914b935f-aad2-427d-a79d-af8a868eae53" />

#### COMPATIBILIDADE  
A ferramenta foi desenvolvida em **MATLAB** e possui uma versão *desktop*, que pode ser utilizada em ambiente offline, e uma versão *webapp*, acessível na intranet. O appAnalise é compatível com as versões mais recentes do MATLAB (ex.: *R2024a* e *R2026a*). A versão compilada — seja *desktop* ou *webapp* — é executada sobre a máquina virtual do MATLAB, o MATLAB Runtime.  

#### EXECUÇÃO NO AMBIENTE DO MATLAB  
Caso o aplicativo seja executado diretamente no MATLAB, é necessário:  
1. Clonar o presente repositório.
2. Clonar também o repositório [SupportPackages](https://github.com/InovaFiscaliza/SupportPackages), adicionando ao *path* do MATLAB as seguintes pastas deste repositório:  
```
.\src\Anatel
.\src\General
.\src\Spectrum
.\src\Propagation
```

3. Abrir o projeto **appAnalise.prj**.
4. Executar **winAppAnalise.mlapp**.

Outras informações em https://anatel365.sharepoint.com/sites/InovaFiscaliza/SitePages/appAnalise.aspx

## Modelo de detecção de emissores (`ai_models/`)

O modelo de IA usado pelo appAnalise (`ai_models/model.onnx`) é treinado e versionado no repositório [code-anatel-axis4](https://github.com/ita-gnss-lab/code-anatel-axis4). Lá ele está registrado como o artefato DVC **`specdet-pmrd-band2`**: um detector de emissores em espectrogramas da faixa PMRD 2 de 4 (70–110 MHz). O arquivo fica armazenado no S3; as versões e os estágios são tags Git gerenciadas pelo [GTO](https://dvc.org/doc/gto).

### Pré-requisitos

- Dependências no ambiente do projeto: `uv add "dvc[s3]" gto`.
- Acesso de leitura ao repositório `ita-gnss-lab/code-anatel-axis4` no GitHub.
- Login na AWS (o remote do DVC usa este perfil):

  ```bash
  aws sso login --profile AdministratorAccess-567736086855
  ```

> Execute os comandos com `uv run`, para garantir que seja usado o `dvc` do `.venv` (que tem o plugin `dvc-s3`) e não uma instalação global.

### Consultar versões e estágios

```bash
REPO=https://github.com/ita-gnss-lab/code-anatel-axis4

uv run gto show specdet-pmrd-band2 --repo $REPO                     # versões, estágios, datas e tags
uv run gto show 'specdet-pmrd-band2#demo' --repo $REPO --version    # versão atualmente no estágio demo (ex.: v0.1.0)
uv run gto history specdet-pmrd-band2 --repo $REPO                  # histórico de registros e atribuições de estágio
```

### Baixar o modelo

```bash
uv run dvc artifacts get $REPO specdet-pmrd-band2 --stage demo -o ai_models
```

O comando baixa a versão atribuída ao estágio `demo` em `ai_models/model.onnx`. Para baixar uma versão específica, troque `--stage demo` por `--rev v0.1.0`. A mensagem `Failed to download artifact ... via Studio - No studio config` pode ser ignorada: o DVC tenta primeiro o Studio e, em seguida, baixa do S3.

> O `dvc artifacts get` apenas copia o arquivo; ele não registra qual versão foi baixada. Use `gto show` para confirmar a versão em uso.

### Metadados do modelo

O ONNX exporta somente a rede (espectrograma → predições por âncora). A geração das âncoras e o pós-processamento (limiar de score, decodificação das caixas e NMS) devem ser feitos pela aplicação. Os parâmetros necessários estão nos metadados do próprio arquivo:

```bash
uv run python -c "import onnx; m = onnx.load('ai_models/model.onnx'); [print(p.key, '=', p.value) for p in m.metadata_props]"
```


