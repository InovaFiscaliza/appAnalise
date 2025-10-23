# appAnalise  [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/InovaFiscaliza/appAnalise)


O appAnalise é uma ferramenta de pós-processamento de dados gerados em monitorações do espectro de radiofrequências conduzidas pelos principais receptores e analisadores de espectro disponíveis na Agência. 
- O app faz a leitura de arquivos gerados por diversas ferramentas, incluindo o Logger (da CRFS), Argus (da Rohde & Schwarz), CellSpectrum (da CellPlan) e appColeta.
- O app possibilita a automação dos processos de detecção e classificação de emissões, geração de relatórios e o upload dos relatórios no SEI por meio de API do eFiscaliza.

PLAYBACK
<img width="1920" height="1032" alt="Screenshot 2025-10-23 152452" src="https://github.com/user-attachments/assets/e1b84721-88aa-4e31-90fa-a7d2af54b7e1" />

DRIVE-TEST
<img width="1920" height="1032" alt="Screenshot 2025-10-23 142132" src="https://github.com/user-attachments/assets/0753721f-3536-4fba-8581-d3fa2c6d1229" />

BASE DE DADOS DE ESTAÇÕES DE TELECOMUNICAÇÕES
<img width="1920" height="1032" alt="Screenshot 2025-10-23 142642" src="https://github.com/user-attachments/assets/c2bf61f6-9b85-4b3b-a5e4-574ea49a7e59" />

#### COMPATIBILIDADE  
A ferramenta foi desenvolvida em **MATLAB** e possui uma versão *desktop*, que pode ser utilizada em ambiente offline, e uma versão *webapp*, acessível na intranet. O appAnalise é compatível com as versões mais recentes do MATLAB (ex.: *R2024a* e *R2025a*). A versão compilada — seja *desktop* ou *webapp* — é executada sobre a máquina virtual do MATLAB, o MATLAB Runtime.  

#### EXECUÇÃO NO AMBIENTE DO MATLAB  
Caso o aplicativo seja executado diretamente no MATLAB, é necessário:  
1. Clonar o presente repositório.
2. Clonar também o repositório [SupportPackages](https://github.com/InovaFiscaliza/SupportPackages), adicionando ao *path* do MATLAB as seguintes pastas deste repositório:  
```
.\src\Anatel
.\src\General
.\src\Spectrum
```

3. Abrir o projeto **appAnalise.prj**.
4. Executar **appAnalise.mlapp**.

Outras informações em https://anatel365.sharepoint.com/sites/InovaFiscaliza/SitePages/appAnalise.aspx
