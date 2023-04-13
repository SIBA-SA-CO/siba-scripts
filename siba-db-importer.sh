#!/bin/bash
#
#1. Parametros recibidos por la linea de comandos, definidos como opciones
#
#    -d -> DB Name
#    -c -> Container DB Name
#    -f -> How many files clean_db-$3.sql must the script iterates.


#Importa los datos de configuracion del archivo .env
source .env

: << 'COMMENT'
Definir las opciones y sus valores por defecto
COMMENT
# Definir las opciones y sus valores por defecto
dbName=""
containerDbName=""
qtyCleanFiles=0

# Analizar las opciones de línea de comandos
while getopts ":d:c:f:" opt; do
  case $opt in
    d) dbName=$OPTARG;;
    c) containerDbName=$OPTARG;;
    f) qtyCleanFiles=$OPTARG;;
    \?) echo "Opción inválida: -$OPTARG" >&2;;
    :) echo "La opción -$OPTARG requiere un argumento." >&2;;
  esac
done




rm -f "$PATH_TO_FILES/$dbName.sql.tar.gz"
rm -f "$PATH_TO_FILES/home/siba/exports/$dbName.sql"
echo "Recuperando el archivo SQL de la fuente $WEB_SOURCE/$dbName.sql.tar.gz"
wget -O "$PATH_TO_FILES/$dbName.sql.tar.gz" "$WEB_SOURCE/$dbName.sql.tar.gz"
pwd
cd $PATH_TO_FILES
pwd
tar --directory "$PATH_TO_FILES/" -xvf "$PATH_TO_FILES/$dbName.sql.tar.gz"
echo "$?"
#docker exec -i std-totalplay /usr/bin/php /var/www/app/artisan down
for ((i=1;i<=$qtyCleanFiles;i++ )); do
        echo "Printing forloop at $i"
        docker exec -i "$containerDbName" sh -c "exec mysql -u $DB_USER -p\"$DB_PWD\" $dbName" < "/home/sibaops/scripts/cleandbscripts/$dbName/clean_db-$i.sql" # & > /dev/null
        echo "$?"
done
chmod -Rf 777 "$PATH_TO_FILES/home/siba/exports/$dbName.sql"
docker exec -i "$containerDbName" sh -c "exec mysql -u $DB_USER -p\"$DB_PWD\" $dbName" < "$PATH_TO_FILES/home/siba/exports/$dbName.sql"
~                                                                                                                                                                                                      
~                                                                                                                                       