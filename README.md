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
./main.sh --proteoma proteoma.fasta --output resultados --gram negative
