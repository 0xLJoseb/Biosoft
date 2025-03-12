#!/bin/bash
#Codigo encargado de instalar en el equipo todo lo que se necesita para ejecutar el script sin problema.


#DOCKER

#Quitar comentarios si es necesario instalar docker.
#Instalando Docker
#echo "[?/?] Instalando Docker..."
#sudo apt-get update && sudo apt-get install -y docker.io docker-compose wget tar
#sudo systemctl enable docker
#sudo usermod -aG docker $USER #Ejecutamos Docker sin sudo

#Verif para perl...
echo "[1/5] Verificando Perl..."
if ! command -v perl &>/dev/null; then
    echo "[X] Perl no encontrado. Instalando..."
    if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y perl
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm perl
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y perl
    else
        echo "[X] No se pudo instalar Perl. Intente manualmente."
        exit 1
    fi
    echo "[✔] Perl instalado correctamente."
else
    echo "[✔] Perl ya está instalado."
fi

#Instalando PSORTB (Docker)
echo "[2/5] Instalando PSORTb..."
sudo docker pull brinkmanlab/psortb_commandline:1.0.2
wget https://raw.githubusercontent.com/brinkmanlab/psortb_commandline_docker/master/psortb
chmod +x psortb

#Instalando Deeploc (entorno virtual)
echo "[3/5] Instalando deeplocpro..."
#Instalamos python3-venv
sudo apt install python3-venv
#Creamos entorno virtual
python3 -m venv venv_deeploc && source venv_deeploc/bin/activate
git clone https://github.com/Jaimomar99/deeplocpro
pip install ./deeplocpro
deactivate

#Instalar NLStradamus
echo "[4/5] Instalando NLStradamus..."
wget http://www.moseslab.csb.utoronto.ca/NLStradamus/NLStradamus/NLStradamus.1.8.tar.gz -O NLStradamus.tar.gz
if [ ! -f "NLStradamus.tar.gz" ]; then
	echo "Error: Fallo en la descarga de NLStradamus."
	exit 1
fi

tar -xzf NLStradamus.tar.gz
mkdir NLStradamus
mv CHANGELOG.txt example* NLStradamus.cpp README* mcm3.fasta nlstradamus.pl NLStradamus
rm NLStradamus.tar.gz

#Verif
echo "[5/5] Verificando dependencias..."
#Verif deeploc
source venv_deeploc/bin/activate && python3 -c "import deeplocpro" && deactivate
if [ $? -eq 0 ]; then
	echo "[+] deeplocpro instalado."
else
	echo "[X] Error: deeplocpro no se pudo importar."
	exit 1
fi
#Verif psortb & NLStradamus

[ -f "psortb" ] && echo "[+] PSORTb instalado." || echo "[X] Error: PSORTb no encontrado."
[ -d "NLStradamus" ] && echo "[+] NLStradamus instalado." || echo "[X] Error: NLStradamus no encontrado."

echo "[+] Instalación completada. Cerrar y reiniciar la terminal."

#Posibles problemas con docker
#Archlinux? --> pacman -S docker
#systemctl start docker

#Posibles problemas con perl
#Archlinux? --> sudo pacman -Sy --noconfirm perl
