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

## Modelos de detecção de emissores (`ai_models/`)

Os modelos de IA usados pelo appAnalise (SpecDet) são treinados e versionados no repositório [code-anatel-axis4](https://github.com/ita-gnss-lab/code-anatel-axis4). Há um modelo por faixa, registrado como o artefato DVC **`specdet-<faixa>`** (ex.: `specdet-pmrd-band2`, detector de emissores em espectrogramas da faixa PMRD 2 de 4, 70–110 MHz). Os arquivos ficam no S3; as versões e os estágios são tags Git gerenciadas pelo [GTO](https://dvc.org/doc/gto).

### Pré-requisitos

- Dependências Python do projeto (`dvc[s3]`, que inclui o `gto`): `uv sync`.
- `uv` no PATH do MATLAB.
- Acesso de leitura ao repositório `ita-gnss-lab/code-anatel-axis4` no GitHub.
- Login na AWS (o remote do DVC usa este perfil):

  ```bash
  aws sso login --profile AdministratorAccess-567736086855
  ```

### Consultar versões e estágios

```bash
REPO=https://github.com/ita-gnss-lab/code-anatel-axis4

uv run gto show --repo $REPO                                        # todos os artefatos (um por faixa)
uv run gto show specdet-pmrd-band2 --repo $REPO                     # versões, estágios, datas e tags de uma faixa
uv run gto show 'specdet-pmrd-band2#demo' --repo $REPO --version    # versão atualmente no estágio demo (ex.: v0.1.0)
uv run gto history specdet-pmrd-band2 --repo $REPO                  # histórico de registros e atribuições de estágio
```

### Baixar e registrar o modelo de uma faixa

No MATLAB, com a pasta `ai_models` no path, informe a faixa (sufixo do artefato) e a versão ou o estágio:

```matlab
fetchSpecDetModel("pmrd-band2", "v0.1.0")   % versão
fetchSpecDetModel("pmrd-band2", "demo")     % estágio (convertido na versão que ele aponta)
```

A função baixa o ONNX da tag `specdet-<faixa>@<versão>`, lê os parâmetros do modelo dos metadados do ONNX, importa a rede no MATLAB e a registra para a faixa. São gerados, em `ai_models/`, com `<base>` = `specdet_<faixa>_<versão>`:

| Arquivo | Conteúdo |
|---|---|
| `<base>.onnx` | Modelo baixado do DVC. |
| `<base>.json` | Parâmetros usados pelo appAnalise, lidos dos metadados do ONNX: grade do espectrograma, janela, âncoras, níveis da pirâmide, decodificação das caixas e pós-processamento. |
| `<base>.mat` | Rede importada e inicializada. |
| `+<namespace>/` | Camadas geradas pelo importador (não versionada). |
| `specdet_models.json` | Registro com o modelo em uso em cada faixa. |

O appAnalise escolhe o modelo de cada fluxo pela faixa: oferece o SpecDet quando os limites do fluxo coincidem com `RfMinHz` e `RfMaxHz` de um modelo registrado. Assim, faixas diferentes podem usar modelos e versões diferentes. O nome dos arquivos carrega a versão, e não o estágio, que pode mudar de versão. Após registrar um modelo com o appAnalise aberto, execute `clear util.SpecDet` para recarregá-lo. O `deploy/compileLinux.m` inclui no executável todos os modelos registrados.

### Metadados do modelo

O ONNX exporta somente a rede (espectrograma → predições por âncora). A geração das âncoras e o pós-processamento (limiar de score, decodificação das caixas e NMS) são feitos pela aplicação (`src/+util/SpecDet.m`), com os parâmetros gravados pelo code-anatel-axis4 nos metadados do ONNX (`metadata_props`, a partir de v0.2.0): `artifact_name`, `version`, `input_hw`, `rf_min_hz`, `rf_max_hz`, `delta_f_hz`, `window_stride`, `bifpn_level_shapes`, `anchor_scales`, `anchor_ratios`, `anchor_base_size_factor`, `max_width_delta`, `max_height_delta`, `score_threshold`, `nms_iou_threshold`, `topk_pre_nms` e `topk_post_nms`. O `fetchSpecDetModel` lê esses metadados diretamente no MATLAB, sem dependências Python.


