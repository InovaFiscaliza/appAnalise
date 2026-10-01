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
