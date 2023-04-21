#!/bin/bash
#
#1. Parametros recibidos por la linea de comandos, definidos como opciones
#
#    -d ->  DB Name
#    -c ->  (Containerized) It indicates whether mysql/mariadb is runing inside a container technology or not.
#    -f ->  How many files clean_db-$3.sql must the script iterates. (optional)
#    -i ->  Input file name, without extension file name (optional)
#    -s ->  Source, The source where the file comes from, if not defined, it takes WEB_SOURCE from .env
#           It supports:
#           - http resources (web resource)
#           - local resource (same directory as PATH_TO_FILES in .env)
#           - File system resource (path to another local directory)


#Importa los datos de configuracion del archivo .env
source .env

: << 'COMMENT'
Definir las opciones y sus valores por defecto
COMMENT
# Definir las opciones y sus valores por defecto
dbName=""
qtyCleanFiles=0
containerized="0"
inputFileName=""
sourceFile=""

# Analizar las opciones de línea de comandos
while getopts ":d:c:f:i:s:" opt; do
  case $opt in
    d) dbName=$OPTARG;;
    c) containerized=$OPTARG;;
    f) qtyCleanFiles=$OPTARG;;
    i) inputFileName=$OPTARG;;
    s) sourceFile=$OPTARG;;
    \?) echo "Opción inválida: -$OPTARG" >&2;;
    :) echo "La opción -$OPTARG requiere un argumento." >&2;;
  esac
done



echo "Containerized: $containerized"

if [[ -z $dbName ]]
then
    echo "No se ha definido el nombre de la base de datos, este valor es obligatorio"
    exit
fi


if [[ -z $inputFileName ]]
then
    inputFileName="$dbName"
fi





if [[ "$sourceFile" == "local" ]]
then
    echo "Tomando fuente la carpeta: $PATH_TO_FILES"
    rm -f "$PATH_TO_FILES/$inputFileName.sql"
else
    if [[ -z sourceFile ]]
    then
        #default behavior
        echo "Recuperando el archivo SQL de la fuente $WEB_SOURCE/$inputFileName.sql.tar.gz"
        rm -f "$PATH_TO_FILES/$inputFileName.sql.tar.gz"
        rm -f "$PATH_TO_FILES/$inputFileName.sql"
        wget -O "$PATH_TO_FILES/$inputFileName.sql.tar.gz" "$WEB_SOURCE/$inputFileName.sql.tar.gz"
    else
        httpRegexp="^http"
        if [[ $sourceFile =~ $httpRegexp ]]
        then
            echo "Recuperando el archivo SQL de la fuente $sourceFile/$inputFileName.sql.tar.gz"
            rm -f "$PATH_TO_FILES/$inputFileName.sql.tar.gz"
            rm -f "$PATH_TO_FILES/$inputFileName.sql"
            wget -O "$PATH_TO_FILES/$inputFileName.sql.tar.gz" "$sourceFile/$inputFileName.sql.tar.gz"    
        else
            if [[ "$PATH_TO_FILES" != "$sourceFile" ]]
            then
                echo "Recuperando el archivo SQL de la fuente $sourceFile/$inputFileName.sql.tar.gz"
                rm -f "$PATH_TO_FILES/$inputFileName.sql.tar.gz"
                rm -f "$PATH_TO_FILES/$inputFileName.sql"
                cp "$sourceFile/$inputFileName.sql.tar.gz" "$PATH_TO_FILES/$inputFileName.sql.tar.gz"
            else
                echo "Tomando como fuente la carpeta: $sourceFile"
                rm -f "$PATH_TO_FILES/$inputFileName.sql"
            fi    
        fi 
    fi
fi
pwd
cd $PATH_TO_FILES
pwd
tar --directory "$PATH_TO_FILES/" -xvf "$PATH_TO_FILES/$inputFileName.sql.tar.gz"
echo "$?"
#docker exec -i std-totalplay /usr/bin/php /var/www/app/artisan down
for ((i=1;i<=$qtyCleanFiles;i++ )); do
        echo "Printing forloop at $i"
        if [[ "$containerized" != '0' ]]
        then
            echo "Limpiando datos previos de la DB contenerizada"
            docker exec -i "$containerized" sh -c "exec mysql -u $DB_USER -p\"$DB_PWD\" $dbName" < "$PATH_TO_FILES/cleandbscripts/$dbName/clean_db-$i.sql"
        else
            echo "Limpiando datos previos de la DB que corre directamente en el servidor"
            mysql -u "$DB_USER" --password="$DB_PWD" "$dbName" < "$PATH_TO_FILES/cleandbscripts/$dbName/clean_db-$i.sql"
        fi
        echo "$?"
done



chmod -Rf 777 "$PATH_TO_FILES/$inputFileName.sql"
#docker exec -i "$containerDbName" sh -c "exec mysql -u $DB_USER -p\"$DB_PWD\" $dbName" < "$PATH_TO_FILES/home/siba/exports/$dbName.sql"

if [[ "$containerized" != '0' ]]
then
    echo "Limpiando datos previos de la DB contenerizada"
    docker exec -i "$containerized" sh -c "exec mysql -u $DB_USER -p\"$DB_PWD\" $dbName" < "$PATH_TO_FILES/$inputFileName.sql"
else
    echo "Limpiando datos previos de la DB que corre directamente en el servidor"
    mysql -u "$DB_USER" --password="$DB_PWD" "$dbName" < "$PATH_TO_FILES/$inputFileName.sql"
fi
~                                                                                                                                                                                                      
~                                                                                                                                       