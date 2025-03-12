# Biosoft
Automatiza el proceso de localización subcelular de proteínas utilizando herramientas bioinformáticas como PSORTb, DeepLocPro 1.0 y NLStradamus.
## Requisitos
- **Dependencias:**
  - Docker (para PSORTb).
- **Requisitos del sistema:**
  - Memoria RAM suficiente (recomendado al menos 8 gb de RAM disponibles).
  - Conexión a Internet (para descargar dependencias y conectar con PSORTb).

## Instalación
1. Clonar el repositorio:
   ```bash
   git clone https://github.com/0xLJoseb/Biosoft.git
   cd Biosoft
2. Ejecutar el script de dependencias **dependencies.sh** 
   ```bash
   ./dependencies.sh
  
## Uso
```bash
BIOSOFT: Automatiza la predicción de localización subcelular y NLS usando PSORTb, Deeplocpro y NLStradamus.
[*]Uso: ./main.sh [OPCIONES]

OPCIONES:
  --site SITE        Lugar de localización a analizar. Por defecto: Extracellular.
     [*] Extracellular
     [*] Periplasmic
     [*] Outer Membrane
  --gram GRAM        Grupo Gram del organismo (negative, positive, archaea). Por defecto: negative.
  --proteoma FILE    Archivo FASTA con el proteoma de entrada. Por defecto: proteoma.fasta.
  --output DIR       Directorio de salida para los resultados. Por defecto: resultados/.
  --threads N        Número de hilos para NLStradamus. Por defecto: todos los núcleos disponibles.
  --help             Muestra este mensaje de ayuda.

#Ejemplo:
  ./main.sh --proteoma proteoma.fasta --output resultados --gram negative --site Extracellular
```

## Resultados
- psortb_results/: Predicciones de PSORTb.
- deeploc_results/: Predicciones de DeepLoc.
- Comb/: Directorio con un CSV con ambas predicciones.
- NLSPredicts/: Directorio con un CSV con resultados de NLS.

## Herramientas Utilizadas
Este proyecto utiliza las siguientes herramientas bioinformáticas:

- **PSORTb**  
  Herramienta para predecir la localización subcelular de proteínas en bacterias. Disponible en: [brinkmanlab/psortb_commandline_docker](https://github.com/brinkmanlab/psortb_commandline_docker).  

- **DeepLoc**  
  Herramienta de predicción de localización subcelular basada en redes neuronales. Disponible en: [Jaimomar99/deeplocpro](https://github.com/Jaimomar99/deeplocpro).  

- **NLStradamus**  
  Herramienta para predecir señales de localización nuclear (NLS). Disponible en: [NLStradamus](http://www.moseslab.csb.utoronto.ca/NLStradamus/).  

[![PSORTb](https://img.shields.io/badge/PSORTb-GitHub-blue)](https://github.com/brinkmanlab/psortb_commandline_docker)
[![DeepLoc](https://img.shields.io/badge/DeepLoc-GitHub-green)](https://github.com/Jaimomar99/deeplocpro)

## Referencias
- **PSORTb**

  PSORTb v3.0: N.Y. Yu, J.R. Wagner, M.R. Laird, G. Melli, S. Rey, R. Lo, P. Dao, S.C. Sahinalp, M. Ester, L.J. Foster, F.S.L. Brinkman (2010) PSORTb 3.0: Improved protein subcellular localization prediction with refined localization subcategories and predictive capabilities for all prokaryotes, Bioinformatics 26(13):1608-1615
- **DeepLocPro**

  Jaime Moreno, Henrik Nielsen, Ole Winther, Felix Teufel (2024). Predicting the subcellular location of prokaryotic proteins with DeepLocPro. Bioinformatics. 10.1093/bioinformatics/btae677
- **NLStradamus**  

  Nguyen Ba, A. N., Pogoutse, A., Provart, N., & Moses, A. M. (2009). NLStradamus: a simple Hidden Markov Model for nuclear localization signal prediction. *BMC Bioinformatics*, *10*(1), 202. https://doi.org/10.1186/1471-2105-10-202  
