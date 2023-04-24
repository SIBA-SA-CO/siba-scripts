#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/kerberos/sbin:/usr/kerberos/bin"
#
#1. Parametros recibidos por la linea de comandos
#
#    -d -> DB Name
#    -o -> Output file name, without extension file name (optional)
#    -t -> (Tables) Comma separated string of table names to export to, if not defined, it's going to export all DB's tables. (optional)
#    -c -> (Containerized) It indicates whether mysql/mariadb is runing inside a container technology or not.

#Loads param variables

SCRIPT_PATH="${BASH_SOURCE:-$0}"
ABS_SCRIPT_PATH="$(realpath "${SCRIPT_PATH}")"
ABS_DIRECTORY="$(dirname "${ABS_SCRIPT_PATH}")"
source "${ABS_DIRECTORY}/.env"

# Define funciones
# ===========================================================
# Función que convierte una cadena de caracteres con valores
# separados por comas, en una cadena con valores separados por
# espacios
#
# Ejemplo de uso:
# cadena_con_comas="valor1,valor2,valor3"
# cadena_con_espacios=$(convertir_comas_a_espacios "$cadena_con_comas")
# echo "$cadena_con_espacios"  # Salida: "valor1 valor2 valor3"

function convertir_comas_a_espacios() {
    # Obtener la cadena de entrada como primer argumento
    cadena="$1"

    # Reemplazar todas las comas por espacios y guardar el resultado en una variable nueva
    nueva_cadena="${cadena//,/ }"

    # Imprimir la nueva cadena
    echo "$nueva_cadena"
}


# Definir las opciones y sus valores por defecto
dbName=""
outputFileName=""
tablesToExport="All"
containerized="0"

# Analizar las opciones de línea de comandos
while getopts ":d:o:t:c:" opt; do
  case $opt in
    d) dbName=$OPTARG;;
    o) outputFileName=$OPTARG;;
    t) tablesToExport=$OPTARG;;
    c) containerized=$OPTARG;;
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


if [[ -z $outputFileName ]]
then
    outputFileName="$dbName"
fi

echo "Iniciando el proceso"

#Borra los archivos procesados anteriormente (de existir)
echo "Borrando los archivos iniciales"
/bin/rm -f "$PATH_TO_FILES/$outputFileName.sql"
/bin/rm -f "$PATH_TO_FILES/$outputFileName.sql.tar.gz"
/bin/rm -f "$PATH_TO_WEB_FOLDER/$outputFileName.sql.tar.gz"

#Exporta los datos desde Mysql
echo "Iniciando la exportación de datos mysql"

if [[ "$tablesToExport" == "All"  ]]
then
    if [[ "$containerized" != '0' ]]
    then
        echo "Exportando desde una base de datos contenerizada"
	docker exec -i "$containerized" sh -c "exec mysqldump -u $DB_USER -p\"$DB_PWD\" $dbName" > "$PATH_TO_FILES/$outputFileName.sql"
    else
        echo "Exportando datos desde una instancia de DB que corre directamente en el servidor"
        /usr/bin/mysqldump -u "$DB_USER" --password="$DB_PWD" "$dbName" > "$PATH_TO_FILES/$outputFileName.sql"
    fi
else
    canalesForMysqldump=$(convertir_comas_a_espacios "$tablesToExport")
    if [[ "$containerized" != '0' ]]
    then
        echo "Exportando desde una base de datos contenerizada"
	docker exec -i "$containerized" sh -c "exec mysqldump -u $DB_USER -p\"$DB_PWD\" --no-create-info $dbName $canalesForMysqldump" > "$PATH_TO_FILES/$outputFileName.sql"
    else
        echo "Exportando datos desde una instancia de DB que corre directamente en el servidor"
	/usr/bin/mysqldump -u "$DB_USER" --password="$DB_PWD" --no-create-info "$dbName" $canalesForMysqldump > "$PATH_TO_FILES/$outputFileName.sql"
    fi
fi


#Prepara el archivo a exportar
cd "$PATH_TO_FILES"
echo "Comprimiendo el archivo $PATH_TO_FILES/$outputFileName.sql.tar.gz"
/bin/tar -czvf "$outputFileName.sql.tar.gz" -C "$PATH_TO_FILES" "$outputFileName.sql"
/bin/chmod 777 "$PATH_TO_FILES/$outputFileName.sql.tar.gz"
/bin/mv "$PATH_TO_FILES/$outputFileName.sql.tar.gz" "$PATH_TO_WEB_FOLDER"
/bin/chown -f siba:siba "$PATH_TO_WEB_FOLDER/$outPutFileName.sql.tar.gz"
/bin/rm "$PATH_TO_FILES/$outputFileName.sql"
