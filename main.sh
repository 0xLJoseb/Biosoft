#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Archivo main
set -euo pipefail #Script termina si cualquier comando falla, script termina si se usa una variable no definida, script falla si cualquier pipe falla

#Valores por defecto
GRAM_GROUP="negative"
PROTEOMA_INPUT="proteoma.fasta"
OUTPUT_DIR="resultados"
THREADS=$(nproc) #Todos los nucleos posibles


# *************** Menu de Ayuda ***************
show_help() {
   
   
    echo -e "${purpleColour}\nBIOSOFT:${endColour} ${yellowColour}Automatiza la predicción de localización subcelular y NLS usando PSORTb, Deeplocpro y NLStradamus.${endColour}"
    echo -e "${yellowColour}[*]${endColour}${grayColour}Uso: $0 [OPCIONES]\n${endColour}"
    echo
    echo -e "${purpleColour}OPCIONES:${endColour}"
    echo -e "  ${redColour}--gram GRAM${endColour}        ${yellowColour}Grupo Gram del organismo (negative, positive, archaea). Por defecto:${endColour} ${redColour}negative.${endColour}"
    echo -e "  ${redColour}--proteoma FILE${endColour}    ${yellowColour}Archivo FASTA con el proteoma de entrada. Por defecto:${endColour} ${redColour}proteoma.fasta.${endColour}"
    echo -e "  ${redColour}--output DIR${endColour}       ${yellowColour}Directorio de salida para los resultados. Por defecto:${endColour} ${redColour}resultados/.${endColour}"
    echo -e "  ${redColour}--threads N${endColour}        ${yellowColour}Número de hilos para NLStradamus. Por defecto:${endColour} ${redColour}todos los núcleos disponibles.${endColour}"
    echo -e "  ${yellowColour}--help             Muestra este mensaje de ayuda.${endColour}"
    echo
    echo -e "${grayColour}Ejemplo:${endColour}"
    echo -e "  ${grayColour}$0 --proteoma proteoma.fasta --output resultados --gram negative\n${endColour}"
    exit 0
}

# *************** Mostrar ayuda si no hay argumentos ***************
if [[ $# -eq 0 ]]; then
	show_help
fi

# *************** Entrada de argumentos ***************
while [[ $# -gt 0 ]]; do
	case "$1" in
		--gram)
			GRAM_GROUP="$2" # Se toma el argumento que le sigue a "--gram"
			shift 2 # Se "elimina" a "--gram" y su argumento
			;;
		--proteoma)
			PROTEOMA_INPUT="$2"
			shift 2
			;;
		--output)
			OUTPUT_DIR="$2"
			shift 2
			;;
		--threads)
			THREADS="$2"
			shift 2
			;;
		--help)
			show_help
			;;
		*)
			echo "Opción desconocida: $1" # Mostramos cual fue la opción desconocida
			exit 1
			;;
	esac
done

# ***************verif argumentos ***************

#echo "Procesando el proteoma: $PROTEOMA_INPUT"
#echo "Grupo GRAM seleccionado: $GRAM_GROUP"
#echo "Resultados guardados en: $OUTPUT_DIR"
#echo "Threads: $THREADS"

# *************** Validaciones [1] ***************


[ -f "$PROTEOMA_INPUT" ] || { echo -e "${redColour}[X] Error:${endColour} $PROTEOMA_INPUT no existe."; exit 1; } # Verificamos si el archivo de proteoma de entrada existe o no.


# *************** Creando directorio OUTPUT ***************
mkdir -p $OUTPUT_DIR

# *************** Ejecución PSORTb ***************
run_psortb() {
	echo -e "${purpleColour}[1/5]${endColour} Ejecutando PSORTb (Gram: $GRAM_GROUP)..."

	local PSORTB_FLAG #Ojo: variable PSORTB_FLAG solo accesible dentro de run_psortb()
	case "$GRAM_GROUP" in
		"negative") PSORTB_FLAG="--negative" ;;
		"positive") PSORTB_FLAG="--positive" ;;
		"archaea") PSORTB_FLAG="--archaea" ;;
		*) echo -ne "${redColour}[X]${endColour} Grupo Gram no valido. \nUsando grupo Gram por defecto.\n"; PSORTB_FLAG="--negative" ;;
	esac

	#Se ejecuta psortb
	./psortb -i "$PROTEOMA_INPUT" -r "$OUTPUT_DIR/psortb_results" "$PSORTB_FLAG" > "$OUTPUT_DIR/logs/psortb.log" 2>&1 # Almacenamiento de errores en un .log

	#Filtrando resultados Extracelulares de PSORTb con awk. [Si se desea, aqui se podria poner mas parametros además de Extracellular] -- [Funcionalidad PENDIENTE]
	#Agregar por ejemplo "NO confirmado: ... in_scores && (/Extracellular/  || /Cytoplasmic/) && NF == 3
	echo -e "${yellowColour}[!]${endColour} Filtrando resultados Extracelulares de PSORTb"
	#CONSIDERACIONES: Filtramos en el campo "Localization Scores" porque no siempre todo lo que sea posiblemente extracelular, mostrara este resultado en el campo "Final Prediction".
	awk '/^SeqID:/ {seqid = $2} /Localization Scores:/ {in_scores = 1; next} in_scores && /Extracellular/ {if ($2 > 5.0) print seqid, $1, $2; in_scores = 0}' "$OUTPUT_DIR"/psortb_results/*.txt > $OUTPUT_DIR/psortb_results/output.txt #Aqui eventualmente en lugar de capturar por "*.txt" podriamos acceder al nombre real del archivo generado por psortb que se almacena en la carpeta de logs -- [FUNC. PENDIENTE]
	
	echo -e "${yellowColour}[!]${endColour} El filtrado se ha almacenado en la ruta: $OUTPUT_DIR/psortb_results/"
	
	local VALOR_EXT
	VALOR_EXT=$(cat $OUTPUT_DIR/psortb_results/output.txt | wc -l)
	echo -e "${yellowColour}[!]${endColour} Se han encontrado $VALOR_EXT proteinas extracelulares."; sleep 3
}

# *************** Ejecución de deeplocpro ***************

run_deeploc(){
	echo -e "\n${purpleColour}[2/5]${endColour} Ejecutando deeplocpro (Gram: $GRAM_GROUP)..."
#Creación de deeploc_flag
	local deeploc_flag
	case "$GRAM_GROUP" in
		"negative") deeploc_flag="negative" ;;
		"positive") deeploc_flag="positive" ;;
		"archaea") deeploc_flag="archaea" ;;
		*) echo -ne "${redColour}[X]${endColour}Grupo Gram no valido. \nUsando grupo Gram por defecto.\n"; deeploc_flag="negative" ;;
	esac


#Activamos el entorno virtual para deeplocpro
	source venv_deeploc/bin/activate

	#DO YOU WANT TO GENERATE PLOTS FOR EACH PROTEIN?
	#deeplocpro -f $PROTEOMA_INPUT -o $OUTPUT_DIR/deeploc_results -g $deeploc_flag -p
	deeplocpro -f $PROTEOMA_INPUT -o $OUTPUT_DIR/deeploc_results -g $deeploc_flag

	#Filtrando resultados extracelulares de deeplocpro con grep
	cat $OUTPUT_DIR/deeploc_results/results*csv | grep "Extracellular" > $OUTPUT_DIR/deeploc_results/Extracellular_records.txt
	echo -e "${yellowColour}[!]${endColour} El filtrado se ha almacenado en la ruta: $OUTPUT_DIR/deeploc_results/"

	local VALOR_EXT
	VALOR_EXT=$(tail -n +2 "$OUTPUT_DIR/deeploc_results/Extracellular_records.txt" | wc -l)
	echo -e "${yellowColour}[!]${endColour} Se han encontrado $VALOR_EXT proteinas extracelulares."; sleep 3

	deactivate #Desactivamos el venv

}

# *************** Combinando info en un solo archivo CSV ***************
combine_predicts(){
	#Comb directory
	echo -ne "\n${purpleColour}[3/5]${endColour} Llevando a cabo el proceso de combinación de predicciones..."
	mkdir -p "$OUTPUT_DIR/Comb"
	echo -ne "\n${yellowColour}[!]${endColour} Realizando tratamientos sobre los datos obtenidos...\n"
	
	sed -i 's/ /,/g' "$OUTPUT_DIR/psortb_results/output.txt" | xargs awk -F',' '{ $NF = $NF / 10; print $0 }' OFS=',' "$OUTPUT_DIR/psortb_results/output.txt" > "$OUTPUT_DIR/Comb/output_arreglado.csv"
	if [[ $? -eq 0 ]]; then
		echo -ne "\t${greenColour}[+]${endColour} PSORTb results created.\n"
	else
		echo -ne "\t${redColour}[X]${endColour} Algo ha salido mal.\n"

	fi

	awk -F',' 'NR>1 {print $2 "," $3 "," $5}' "$OUTPUT_DIR/deeploc_results/Extracellular_records.txt" > "$OUTPUT_DIR/Comb/Extracellular_records_arreglado.csv"
	
	if [[ $? -eq 0 ]]; then
		echo -ne "\t${greenColour}[+]${endColour} Deeploc results created.\n"
	else
		echo -ne "\t${redColour}[X]${endColour} Algo ha salido mal.\n"

	fi

#  ======= combinar.py =======

	python3 bin/combinar.py --psortb "$OUTPUT_DIR/Comb/output_arreglado.csv" --deeploc "$OUTPUT_DIR/Comb/Extracellular_records_arreglado.csv" --output "$OUTPUT_DIR/Comb/archivo_combinado.csv"
	
	if [[ $? -eq 0 ]]; then
		echo -ne "\t${greenColour}[+]${endColour} The predictions have been succesfully combined!.\n"
	else
		echo -ne "\t${redColour}[X]${endColour} Algo ha salido mal.\n"

	fi


# ======= extraer.py =======
#Se crea un FASTA con las secuencias en AA's para todo lo predicho

	mkdir -p "$OUTPUT_DIR/NLSPredicts"
	echo -ne "${purpleColour}[4/5]${endColour} Generando un archivo .fasta con las proteinas predichas como Extracelulares por PSORTb & Deeplocpro¸\n"
	python3 bin/extraer.py --score "$OUTPUT_DIR/Comb/archivo_combinado.csv" --fasta "$PROTEOMA_INPUT" --output "$OUTPUT_DIR/NLSPredicts/Extracellular_proteins.fasta"
	
	if [[ $? -eq 0 ]]; then
		echo -ne "\t${greenColour}[+]${endColour} The .fasta file has been succesfully created!.\n"
	else
		echo -ne "\t${redColour}[X]${endColour} Something has gone wrong.\n"

	fi

}

run_nlstradamus(){

	echo -ne "\n${purpleColour}[5/5]${endColour} Realizando el análisis de NLS sobre el proteoma generado!\n"
	echo -ne "Default parameters: -t 0.7 (threshold for true NLS) and -m 2 (four-state bipartite model for complex NLS detection).\n"
	perl NLStradamus/nlstradamus.pl -i "$OUTPUT_DIR/NLSPredicts/Extracellular_proteins.fasta" -t 0.7 -m 2 -cpu $THREADS -tab | sed 's/\t/,/g' > "$OUTPUT_DIR/NLSPredicts/resultsNLS.csv"
	
	if [[ $? -eq 0 ]]; then
		echo -ne "\t${greenColour}[+]${endColour} NLS predictions have been successfully realized!\n"
		echo -ne "\t${greenColour}[+]${endColour} Check the "$OUTPUT_DIR/NLSPredicts/resultsNLS.csv" directory!\n"
	else
		echo -ne "\t${redColour}[X]${endColour} Something has gone wrong.\n"

	fi

	local VALOR_EXT
	VALOR_EXT=$(tail -n +2 "$OUTPUT_DIR/NLSPredicts/resultsNLS.csv" | wc -l)
	echo -e "${yellowColour}[!]${endColour} Se han encontrado $VALOR_EXT proteinas extracelulares con NLS."; sleep 3


	#-t 0.7: Sets a threshold of 0.7 to consider sites as true NLS.
	#m 2: Uses a bipartite four-state model to improve detection of complex NLS.
	#sed: Converts tabs to commas to generate a CSV.

}

# *************** main ***************
main() {
	mkdir -p "$OUTPUT_DIR"/{logs,psortb_results,deeploc_results}

	#Ejecutar pasos secuencialmente
	run_psortb
	run_deeploc
	combine_predicts
	run_nlstradamus
	
	echo -e "${grayColour}Analisis completado! Resultados en : $OUTPUT_DIR${endColour}"
}

main
