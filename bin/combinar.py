#!/usr/bin/python3
import pandas as pd
import os
import re
import argparse #Para automatizar la entrada
import sys

# Para que se vea ordenado de menor a mayor
def ext_numero(acc_num):
    numeros = re.findall(r'\d+', acc_num) # Busca ultima secuencia de digitos en la cadena
    
    return int(numeros[-1]) if numeros else float('inf') # Si no hay mas numeros retorna infinito

def build_replacements(gram: str): #Diccionario cuya estructura va a cambiar segun el gram
    base = {
        "OuterMembrane" : "Outer Membrane",
        "CytoplasmicMembrane" : "Cytoplasmic Membrane",
    }
    if gram == "positive": #Unificamos psort y deeploc para cell wall en gram pos
        base.update({
            "Cellwall" : "Cell wall",
            "Cell wall & surface" : "Cell wall",
        })
    elif gram == "negative":
        base.update({
            "Cell wall & surface" : "Outer Membrane",
        })
    else:
        pass #solo base 
    return base 

def norm_loc(localization: str, replacements: dict):
    return replacements.get(localization, localization) #Convertimos cada palabra en su respectivo reemplazo
# Configurando agumentos de entrada

parser = argparse.ArgumentParser(description='Combina resultados de PSORTb y Deeplocpro')
parser.add_argument('--psortb', required=True, help='Ruta al archivo CSV de PSORTb')
parser.add_argument('--deeploc', required=True, help='Ruta al archivo CSV de Deeplocpro')
parser.add_argument('--output', required=True, help='Ruta de salida para el archivo CSV combinado')
parser.add_argument('--gram', required=True, choices=['positive', 'negative', 'archaea'], help='Gram escogido para la ejecucion del analisis')
args = parser.parse_args()

ruta_arc1 = args.psortb
ruta_arc2 = args.deeploc

# Cargar CSVs
archivo1 = pd.read_csv(ruta_arc1, header=None, names=["Accession number", "Localization", "Score"])
archivo2 = pd.read_csv(ruta_arc2, header=None, names=["Accession number", "Localization", "Score"])

# Normalizacion loc. 
replacements = build_replacements(args.gram)
archivo1["Localization"] = archivo1["Localization"].apply(lambda x: norm_loc(str(x), replacements))
archivo2["Localization"] = archivo2["Localization"].apply(lambda x: norm_loc(str(x), replacements))


# Verif Vacios & Concatenar

if archivo1.empty and archivo2.empty:
    print("Ambos archivos están vacíos. No hay datos para combinar.")
    sys.exit(1)
elif archivo1.empty:
    print("El archivo de PSORTb está vacío. Usando solo el archivo de Deeploc.")
    combinado = archivo2
elif archivo2.empty:
    print("El archivo de Deeploc está vacío. Usando solo el archivo de PSORTb.")
    combinado = archivo1
else:
    # Concatenar si ambos archivos tienen datos
    combinado = pd.concat([archivo1, archivo2], ignore_index=True)

# Agrupar con groupby columnas: 'Accession number' y 'Localization', y promedio de scores para los duplicados
resultado = combinado.groupby(["Accession number", "Localization"], as_index=False).mean()
resultado["Score"] = resultado["Score"].round(3) #Redondeo

resultado["Accession number numeric"] = resultado["Accession number"].apply(ext_numero) # Aplicamos la funcion
resultado = resultado.sort_values(by="Accession number numeric", ascending=True) # Organizamos por AC numerico

resultado = resultado.drop(columns=["Accession number numeric"]) # Dropeamos la columna AC numeric

resultado.to_csv(args.output, index=False) #Convertimos el DF resultado en un CSV y sin indice.

print(f"El archivo combinado se ha guardado en: {args.output}")

