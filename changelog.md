***************12/03/2025***************

Se han realizado los siguientes cambios en el proyecto en general

 - Cambios en main.sh, ahora el proteoma por defecto es "extracellular.fasta"
 - Cambios en los proteomas de test ((extracellular, periplasmic, outer).fasta), ahora estan anotados con los resultados que deberian obtenerse para verificar que todo esta bien.
 - Cambios en el bin/combinar.py en los casos en los que se hiciera un analisis para localizacion "Outer Membrane" esto debido a que PSORTb y DeepLocPro utilizan "OuterMembrane" y "Outer Membrane" Respectivamente para las proteinas de esta localizacion, se estaban generando registros duplicados en "archivo_combinado.csv", el error fue solucionado mediante una funcion que se encarga de normalizar los nombres de localizacion a "Outer Membrane" en estos casos



***************11/03/2025***************

Se han realizado los siguientes cambios sobre el proyecto en general

 - Cambios en el archivo "main.sh" para la creacion de la flag "Site" que permite la eleccion para predecir sobre mas sitios de localizacion [Extracellular, Periplasmic, Outer Membrane] --> Esto implica tambien una serie de cambios en varias partes del codigo para hacer referencia a la informacion del sitio de localizacion escogido por el usuario.
 
 - En el archivo combinar.py se hicieron ajustes para la situacion en la que alguno de los dos resultados de prediccion (PSORTb | DeepLocPro) se encontraran vacios.
 
 - Se realizaron diversos ajustes de sintaxis a lo largo del código por si el usuario decide colocar un nombre con espacios a la carpeta de output. Además, se arregla el README.md
 
