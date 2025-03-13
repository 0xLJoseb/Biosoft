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
SITE="Extracellular"
GRAM_GROUP="negative"
PROTEOMA_INPUT="extracellular.fasta"
OUTPUT_DIR="resultados"
THREADS=$(nproc) #Todos los nucleos posibles


# *************** Menu de Ayuda ***************
show_help() {
   
   
    echo -e "${turquoiseColour}\nBIOSOFT:${endColour} ${grayColour}Automatiza la predicción de localización subcelular y NLS usando PSORTb, Deeplocpro y NLStradamus.${endColour}"
    echo -e "${redColour}[*]${endColour}${grayColour}Uso: $0 [OPCIONES]\n${endColour}"
    echo
    echo -e "${turquoiseColour}OPCIONES:${endColour}"
    echo -e " ${redColour} --site SITE${endColour}	     ${grayColour}Lugar de localización a analizar. Por defecto:${endColour} ${redColour}Extracellular.${endColour}"
    echo -e "     ${redColour}[*]${endColour} ${grayColour}Extracellular${endColour}"
    echo -e "     ${redColour}[*]${endColour} ${grayColour}Periplasmic${endColour}"
    echo -e "     ${redColour}[*]${endColour} ${grayColour}Outer Membrane${endColour}"
    echo -e "  ${redColour}--gram GRAM${endColour}        ${grayColour}Grupo Gram del organismo (negative, positive, archaea). Por defecto:${endColour} ${redColour}negative.${endColour}"
    echo -e "  ${redColour}--proteoma FILE${endColour}    ${grayColour}Archivo FASTA con el proteoma de entrada. Por defecto:${endColour} ${redColour}proteoma.fasta.${endColour}"
    echo -e "  ${redColour}--output DIR${endColour}       ${grayColour}Directorio de salida para los resultados. Por defecto:${endColour} ${redColour}resultados/.${endColour}"
    echo -e "  ${redColour}--threads N${endColour}        ${grayColour}Número de hilos para NLStradamus. Por defecto:${endColour} ${redColour}todos los núcleos disponibles.${endColour}"
    echo -e "  ${grayColour}--help             Muestra este mensaje de ayuda.${endColour}"
    echo
    echo -e "${grayColour}Ejemplo:${endColour}"
    echo -e "  ${grayColour}$0 --proteoma proteoma.fasta --output resultados --gram negative --site Extracellular\n${endColour}"
    exit 0
}

# *************** Mostrar ayuda si no hay argumentos ***************
if [[ $# -eq 0 ]]; then
	show_help
fi

# *************** Entrada de argumentos ***************
while [[ $# -gt 0 ]]; do
	case "$1" in
		--site)
			SITE="$2"
			shift 2
			;;
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

echo "Sitio de localizacion: $SITE"
echo "Procesando el proteoma: $PROTEOMA_INPUT"
#echo "Grupo GRAM seleccionado: $GRAM_GROUP"
#echo "Resultados guardados en: $OUTPUT_DIR"
#echo "Threads: $THREADS"

# *************** Validaciones [1] ***************


[ -f "$PROTEOMA_INPUT" ] || { echo -e "${redColour}[X] Error:${endColour} $PROTEOMA_INPUT no existe."; exit 1; } # Verificamos si el archivo de proteoma de entrada existe o no.


# *************** Creando directorio OUTPUT ***************
mkdir -p "$OUTPUT_DIR"

# *************** Ejecución PSORTb ***************
run_psortb() {
	echo -e "${purpleColour}[1/5]${endColour} Ejecutando PSORTb (Gram: $GRAM_GROUP)..."

#Creacion de Localization PSORTb flag

	local locPSORTB_FLAG
	case "$SITE" in
		"Extracellular") locPSORTB_FLAG="Extracellular" ;;
		"Periplasmic") locPSORTB_FLAG="Periplasmic" ;;
		"Outer Membrane") locPSORTB_FLAG="OuterMembrane" ;;
		*) echo -ne "${redColour}[X]${endColour} Sitio de localización no valido, o no implementado aun. \nUsando grupo Gram por defecto.\n"; locPSORTB_FLAG="Extracellular" ;;
	esac
        
	local PSORTB_FLAG #Ojo: variable PSORTB_FLAG solo accesible dentro de run_psortb()
	case "$GRAM_GROUP" in
		"negative") PSORTB_FLAG="--negative" ;;
		"positive") PSORTB_FLAG="--positive" ;;
		"archaea") PSORTB_FLAG="--archaea" ;;
		*) echo -ne "${redColour}[X]${endColour} Grupo Gram no valido. \nUsando grupo Gram por defecto.\n"; PSORTB_FLAG="--negative" ;;
	esac

	#Se ejecuta psortb
	./psortb -i "$PROTEOMA_INPUT" -r "$OUTPUT_DIR/psortb_results" "$PSORTB_FLAG" > "$OUTPUT_DIR/logs/psortb.log" 2>&1 # Almacenamiento de errores en un .log

	#Filtrando resultados de proteinas predichas por PSORTb con awk.
	echo -e "${yellowColour}[!]${endColour} Filtrando resultados para el sitio de localizacion: \"$locPSORTB_FLAG"" de PSORTb"
	#CONSIDERACIONES: Filtramos en el campo "Localization Scores" porque no siempre todo lo que sea posiblemente "X" localizacion, mostrara este resultado en el campo "Final Prediction".
	#Pasamos a awk la flag con el parametro -v
	awk -v flag="$locPSORTB_FLAG" '/^SeqID:/ {seqid = $2} /Localization Scores:/ {in_scores = 1; next} in_scores && $0 ~ flag {if ($2 > 5.0) print seqid, $1, $2; in_scores = 0}' "$OUTPUT_DIR"/psortb_results/*.txt > "$OUTPUT_DIR"/psortb_results/output.txt #Aqui eventualmente en lugar de capturar por "*.txt" podriamos acceder al nombre real del archivo generado por psortb que se almacena en la carpeta de logs -- [FUNC. PENDIENTE]
	
	echo -e "${yellowColour}[!]${endColour} El filtrado se ha almacenado en la ruta: "$OUTPUT_DIR"/psortb_results/"
	
	local VALOR_EXT
	VALOR_EXT=$(cat $OUTPUT_DIR/psortb_results/output.txt | wc -l)
	echo -e "${yellowColour}[!]${endColour} Se han encontrado $VALOR_EXT proteinas para el sitio de localizacion: \"$locPSORTB_FLAG\""; sleep 3
}

# *************** Ejecución de deeplocpro ***************

run_deeploc(){
	echo -e "\n${purpleColour}[2/5]${endColour} Ejecutando deeplocpro (Gram: $GRAM_GROUP)..."

#Creación de localization deeploc_flag 
	
	local locdeeploc_flag
	case "$SITE" in
		"Extracellular") locdeeploc_flag="Extracellular" ;;
		"Periplasmic") locdeeploc_flag="Periplasmic" ;;
		"Outer Membrane") locdeeploc_flag="Outer Membrane" ;;
		*) echo -ne "${redColour}[X]${endColour}Sitio de localización no valido, o no implementado aun. \nUsando grupo Gram por defecto.\n"; locPSORTB_FLAG="Extracellular" ;;
	esac
	
#Creación de Gram deeploc_flag
	
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
	#deeplocpro -f $PROTEOMA_INPUT -o "$OUTPUT_DIR"/deeploc_results -g $deeploc_flag -p
	deeplocpro -f $PROTEOMA_INPUT -o "$OUTPUT_DIR"/deeploc_results -g $deeploc_flag

	#Filtrando resultados extracelulares de deeplocpro con grep

	cat "$OUTPUT_DIR"/deeploc_results/results*csv | grep "$locdeeploc_flag" > "$OUTPUT_DIR"/deeploc_results/records.txt
	echo -e "${yellowColour}[!]${endColour} El filtrado se ha almacenado en la ruta: "$OUTPUT_DIR"/deeploc_results/"

	local VALOR_EXT
	VALOR_EXT=$(tail -n +2 ""$OUTPUT_DIR"/deeploc_results/records.txt" | wc -l)
	echo -e "${yellowColour}[!]${endColour} Se han encontrado $VALOR_EXT proteinas con la localizacion: \"$locdeeploc_flag\"."; sleep 3

	deactivate #Desactivamos el venv

}

# *************** Combinando info en un solo archivo CSV ***************
combine_predicts(){


	local loc_flag
	case "$SITE" in
    		"Extracellular") loc_flag="Extracellular" ;;
    		"Periplasmic") loc_flag="Periplasmic" ;;
    		"Outer Membrane") loc_flag="Outer Membrane" ;;
    		*) echo -ne "${redColour}[X]${endColour}Sitio de localización no válido, o no implementado aún. \nUsando grupo Gram por defecto.\n"; loc_flag="Extracellular" ;;
	esac
	

	case "$loc_flag" in
		
    		"Extracellular") score_column=5 ;;
    		"Periplasmic") score_column=9 ;;
    		"Outer Membrane") score_column=8 ;;
    		*) score_column=5 ;;  # Por defecto --> Extracellular
	esac


	#Comb directory
	echo -ne "\n${purpleColour}[3/5]${endColour} Llevando a cabo el proceso de combinación de predicciones..."
	mkdir -p "$OUTPUT_DIR/Comb"
	echo -ne "\n${yellowColour}[!]${endColour} Realizando tratamientos sobre los datos obtenidos...\n"
	
	sed -i 's/ /,/g' "$OUTPUT_DIR/psortb_results/output.txt" | xargs awk -F',' '{ $NF = $NF / 10; print $0 }' OFS=',' "$OUTPUT_DIR/psortb_results/output.txt" > ""$OUTPUT_DIR"/Comb/output_arreglado.csv"
	if [[ $? -eq 0 ]]; then
		echo -ne "\t${greenColour}[+]${endColour} PSORTb results created.\n"
	else
		echo -ne "\t${redColour}[X]${endColour} Algo ha salido mal.\n"

	fi

	awk -F',' -v col="$score_column" 'NR>1 {print $2 "," $3 "," $col}' ""$OUTPUT_DIR"/deeploc_results/records.txt" > ""$OUTPUT_DIR"/Comb/records_arreglado.csv"
	
	if [[ $? -eq 0 ]]; then
		echo -ne "\t${greenColour}[+]${endColour} Deeploc results created.\n"
	else
		echo -ne "\t${redColour}[X]${endColour} Algo ha salido mal.\n"

	fi

#  ======= combinar.py =======

	python3 bin/combinar.py --psortb "$OUTPUT_DIR/Comb/output_arreglado.csv" --deeploc "$OUTPUT_DIR/Comb/records_arreglado.csv" --output "$OUTPUT_DIR/Comb/archivo_combinado.csv"
	
	if [[ $? -eq 0 ]]; then
		echo -ne "\t${greenColour}[+]${endColour} The predictions have been succesfully combined!.\n"
	else
		echo -ne "\t${redColour}[X]${endColour} Algo ha salido mal.\n"

	fi


# ======= extraer.py =======
#Se crea un FASTA con las secuencias en AA's para todo lo predicho

	mkdir -p "$OUTPUT_DIR/NLSPredicts"
	echo -ne "\n${purpleColour}[4/5]${endColour} Generando un archivo .fasta con las proteinas predichas con localizacion \"$loc_flag\""" por PSORTb & Deeplocpro¸\n"
	python3 bin/extraer.py --score "$OUTPUT_DIR/Comb/archivo_combinado.csv" --fasta "$PROTEOMA_INPUT" --output "$OUTPUT_DIR/NLSPredicts/Predicted_proteins.fasta"
	
	if [[ $? -eq 0 ]]; then
		echo -ne "\t${greenColour}[+]${endColour} The .fasta file has been succesfully created!.\n"
	else
		echo -ne "\t${redColour}[X]${endColour} Something has gone wrong.\n"

	fi

}

run_nlstradamus(){

	#loc_flag
	local loc_flag
	case "$SITE" in
		"Extracellular") loc_flag="Extracellular" ;;
    		"Periplasmic") loc_flag="Periplasmic" ;;
    		"Outer Membrane") loc_flag="Outer Membrane" ;;
    		*) echo -ne "${redColour}[X]${endColour}Sitio de localización no válido, o no implementado aún. \nUsando grupo Gram por defecto.\n"; loc_flag="Extracellular" ;;
	esac

	

	echo -ne "\n${purpleColour}[5/5]${endColour} Realizando el análisis de NLS sobre el proteoma generado!\n"
	echo -ne "Default parameters: -t 0.7 (threshold for true NLS) and -m 2 (four-state bipartite model for complex NLS detection).\n"
	perl NLStradamus/nlstradamus.pl -i "$OUTPUT_DIR/NLSPredicts/Predicted_proteins.fasta" -t 0.7 -m 2 -cpu $THREADS -tab | sed 's/\t/,/g' > "$OUTPUT_DIR/NLSPredicts/resultsNLS.csv"
	
	if [[ $? -eq 0 ]]; then
		echo -ne "\t${greenColour}[+]${endColour} NLS predictions have been successfully realized!\n"
		echo -ne "\t${greenColour}[+]${endColour} Check the "$OUTPUT_DIR/NLSPredicts/resultsNLS.csv" directory!\n"
	else
		echo -ne "\t${redColour}[X]${endColour} Something has gone wrong.\n"

	fi

	local VALOR_EXT
	VALOR_EXT=$(tail -n +2 "$OUTPUT_DIR/NLSPredicts/resultsNLS.csv" | wc -l)
	echo -e "${yellowColour}[!]${endColour} Se han encontrado $VALOR_EXT proteinas de localizacion \"$loc_flag\" con NLS."; sleep 3


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
