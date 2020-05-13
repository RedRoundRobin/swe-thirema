#!/bin/sh

#  Copyright 2020
#      ___         __  ___                    __  ___       __   _    
#    / _ \___ ___/ / / _ \___  __ _____  ___/ / / _ \___  / /  (_)__ 
#   / , _/ -_) _  / / , _/ _ \/ // / _ \/ _  / / , _/ _ \/ _ \/ / _ \
#  /_/|_|\__/\_,_/ /_/|_|\___/\_,_/_//_/\_,_/ /_/|_|\___/_.__/_/_//_/
#  
#  mr_wolf.sh - i solve problems for RIoT (Project ThiReMa)
#

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color


startingmessage () {
    echo "${GREEN}[Mr. Wolf]${NC} $1"
    echo "${NC}============================================="
}

finalmessage () {
    echo "${NC} ============================================="
    echo "${NC}> ${ORANGE}Mr. Wolf ${GREEN} solved our ${RED} problems ${NC} <"
}

errormex () {
    echo "${RED}[Errore:] $1"
}

dockercompose_cmd () {
    docker-compose \
        -f riot/docker-compose.riot.yml \
        $1
}

dockercompose_status () {
    dockercompose_cmd "ps"
}

dockercompose_up () {
    echo "${ORANGE}[Mr. Wolf] ${NC} Installazione e avvio dei container Docker in corso..."
    dockercompose_cmd "up --build -d"
    echo "${ORANGE}[Mr. Wolf] ${GREEN} Avvio dei container completato!"
}


dockercompose_start () {
    echo "${ORANGE}[Mr. Wolf] ${NC} Avvio dei container Docker in corso..."
    dockercompose_cmd "start"
    echo "${ORANGE}[Mr. Wolf] ${GREEN} Avvio dei container completato!"
}

dockercompose_stop () {
    echo "${ORANGE}[Mr. Wolf] ${NC} Stop dei servizi attivi ..."
    dockercompose_cmd "stop"
    echo "${ORANGE}[Mr. Wolf] ${GREEN} Stop eseguito!"
}

dockercompose_down () {
    echo "${ORANGE}[Mr. Wolf] ${NC} Rimozione dei servizi attivi, delle immagini e dei volumi ..."
    dockercompose_cmd "down -v"
    docker image prune -f
    echo "${ORANGE}[Mr. Wolf] ${GREEN} Rimozione eseguita!"
}


if [ $# = 0 ] || [ $1 = "help" ]
then
    echo " "
    echo "I'm Mr Wolf. Tell me what the problem is.. "
    echo "[USAGE:] ${ORANGE}mr_wolf.sh ${NC}[command]"
    echo " ${NC}"
    echo "${NC}help      ${NC}Comandi di aiuto per lo script"
    echo "${NC}status      ${NC}Status dei servizi RIoT"
    echo "${GREEN}init      ${NC}Prima installazione e avvio di tutti i servizi RIoT"
    echo "${GREEN}start     ${NC}Avvio di tutti i servizi RIoT"
    echo "${ORANGE}stop      ${NC}Stop di tutti i servizi RIoT"
    echo "${RED}remove    ${NC}Stop e rimozione di tutti i servizi RIoT"

elif [ $1 = "init" ]
then
    if [ -f "./riot/riot-installed.lock" ]
    then 
        errormex "È già presente un'installazione di RIoT. Esegui prima [remove], oppure cancella la cartella (riot/) prima di continuare."
        exit 1
    fi 
    
    startingmessage "Avvio della prima installazione di RIoT"
    echo "${ORANGE}[Mr. Wolf] ${NC} Copia delle componenti software ..."
    mkdir riot
    cp -r kafka-db riot/kafka-db
    cp -r gateway riot/gateway
    cp -r api riot/api
    cp -r telegram riot/telegram
    cp -r webapp riot/webapp
    cp ./docker-compose.riot.yml riot/
    mv ./riot/kafka-db/kafka/* riot/
    touch ./riot/riot-installed.lock
    echo "${ORANGE}[Mr. Wolf] ${GREEN} Componenti copiate con successo!"
    dockercompose_up 
    finalmessage
    exit 0

elif [ $1 = "status" ]
then
    if [ ! -f "./riot/riot-installed.lock" ]
    then 
        errormex "Nessuna installazione del prodotto trovata."
        exit 1
    fi 
    startingmessage "Status dei servizi RIoT"
    dockercompose_status
    exit 0

elif [ $1 = "start" ]
then
    if [ ! -f "./riot/riot-installed.lock" ]
    then 
        errormex "Nessuna installazione del prodotto trovata."
        exit 1
    fi 
    startingmessage "Avvio dei servizi RIoT"
    dockercompose_start
    finalmessage
    exit 0

elif [ $1 = "stop" ]
then 
    if [ ! -f "./riot/riot-installed.lock" ]
    then 
        errormex "Nessuna installazione del prodotto trovata."
        exit 1
    fi 
    startingmessage "Stop dei servizi RIoT"
    dockercompose_stop
    finalmessage
    exit 0

elif [ $1 = "remove" ]
then 
    if [ ! -f "./riot/riot-installed.lock" ]
    then 
        errormex "Nessuna installazione del prodotto trovata."
        exit 1
    fi 
    echo "La rimozione di RIoT comporta la rimozione delle dangling images da docker, dei volumi e dei container."
    read -r -p "Sei sicuro di voler proseguire? [y/N] " response
    if [ "$response" = "y" ] || [ "$response" = "Y" ]
    then
        startingmessage "Stop e rimozione dei servizi RIoT dalla macchina.."
        dockercompose_down
        rm -rf ./riot/   
        finalmessage  
    else
        echo "Pericolo scampato :)"
    fi

    exit 0
fi

