#!usr/bin/python3
import argparse # Manejo de args
from Bio import SeqIO

def extract_proteins(score, fasta, output):
    acc_numbers = set() #Definimos acc_numbers
    with open(score, 'r') as sf:
        next(sf) #Saltamos encabezado
        for line in sf:
            acc = line.split(',')[0].strip() #Tomamos la totalidad del ACC
            acc = acc.split('|')[-1] #Spliteamos por "|" el ACC y tomamos la ultima parte (NO deberia haber problema si el ACC no contiene "|") ? 
            acc_numbers.add(acc) # Agregamos acc a acc_numbers
    
    #print(f"Se encontraron {len(acc_numbers)} ACC Numbers unicos en '{score}'.")

    found = 0
    with open(fasta, 'r', encoding='utf-8') as ff, open(output, 'w') as out_fasta:
        for record in SeqIO.parse(ff, "fasta"):
            #Revisa si el ACC del Fasta está en los ACC filtrados
            acc = record.id.split('|')[-1]
            if acc in acc_numbers:
                SeqIO.write(record, out_fasta, "fasta")
                found +=1

    print(f"Se guardaron {found} secuencias en '{output}'.")

#args
parser = argparse.ArgumentParser(description='Extrae secuencias FASTA a partir de ACC numbers de un archivo CSV.')
parser.add_argument('--score', required=True, help='Ruta al archivo CSV de scores combinados')
parser.add_argument('--fasta', required=True, help='Ruta al archivo FASTA original')
parser.add_argument('--output', required=True, help='Ruta de salida para el archivo FASTA filtrado')
args = parser.parse_args()
#func
extract_proteins(args.score, args.fasta, args.output)
