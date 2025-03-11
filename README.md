# Biosoft
Automatiza el proceso de localización subcelular de proteínas utilizando herramientas bioinformáticas como PSORTb, DeepLocPro 1.0 y NLStradamus.
## Requisitos
- **Dependencias:**
  - Docker (para PSORTb).
- **Requisitos del sistema:**
  - Memoria RAM suficiente (recomendado al menos 8 gb de RAM).
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
  --gram GRAM        Grupo Gram del organismo (negative, positive, archaea). Por defecto: negative.
  --proteoma FILE    Archivo FASTA con el proteoma de entrada. Por defecto: proteoma.fasta.
  --output DIR       Directorio de salida para los resultados. Por defecto: resultados/.
  --threads N        Número de hilos para NLStradamus. Por defecto: todos los núcleos disponibles.
  --help             Muestra este mensaje de ayuda.

#Ejemplo:
  ./main.sh --proteoma proteoma.fasta --output resultados --gram negative
```

## Resultados
- psortb_results/: Predicciones de PSORTb.
- deeploc_results/: Predicciones de DeepLoc.
- Comb/: Directorio con un CSV con ambas predicciones.
- NLSPredicts/: Directorio con un CSV con resultados de NLS.

## Herramientas utilizadas
Este proyecto utiliza las siguientes herramientas:

- **PSORTb**  
  Herramienta para predecir la localización subcelular de proteínas en bacterias. Disponible en: [brinkmanlab/psortb_commandline_docker](https://github.com/brinkmanlab/psortb_commandline_docker).  

- **DeepLoc**  
  Herramienta de predicción de localización subcelular basada en redes neuronales. Disponible en: [Jaimomar99/deeplocpro](https://github.com/Jaimomar99/deeplocpro).

[![PSORTb](https://img.shields.io/badge/PSORTb-GitHub-blue)](https://github.com/brinkmanlab/psortb_commandline_docker)
[![DeepLoc](https://img.shields.io/badge/DeepLoc-GitHub-green)](https://github.com/Jaimomar99/deeplocpro)
