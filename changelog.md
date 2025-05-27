***************26/05/2025***************
The following changes have been made to the overall project:

- The code is gradually being translated into English.
- A new '"Site"' flag has been added [Cytoplasmic]. This required some updates in "main.sh". A new annotated proteome was also added to help test and confirm that everything works as expected with this new '"Site"' flag.
- Some typos were fixed. 

***************12/03/2025***************

The following changes have been made to the overall project:

- Changes in 'main.sh': the default proteome is now '"extracellular.fasta"'.
- Updates to the test proteomes ('extracellular.fasta', 'periplasmic.fasta', and 'outer.fasta'): these files are now annotated with the expected results to verify that everything works correctly.
- Modifications in 'bin/combinar.py' for cases involving the "Outer Membrane" localization: since PSORTb and DeepLocPro use '"OuterMembrane"' and '"Outer Membrane"', respectively, for this localization, duplicate records were being generated in '"archivo_combinado.csv"'. This issue was fixed by adding a function that normalizes localization names to '"Outer Membrane"' in these cases.


***************11/03/2025***************

The following general changes have been made to the project:

- Changes in the 'main.sh' script: a new '"Site"' flag was added to allow selection of additional localization sites for prediction [Extracellular, Periplasmic, Outer Membrane]. This also required changes in various parts of the code to reference the selected localization site information.
- In 'combinar.py', adjustments were made to handle cases where one of the two prediction results (PSORTb | DeepLocPro) was empty.
- Various syntax adjustments were made throughout the code to support output folder names that include spaces. Additionally, the 'README.md' file was updated. 
