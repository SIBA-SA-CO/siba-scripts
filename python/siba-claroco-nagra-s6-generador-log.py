# -*- coding: utf-8 -*-

import os
import time
import sys

folder_path = sys.argv[1]
output_file = sys.argv[2]
cliente = "["+str(sys.argv[3])+"]"
extension = sys.argv[4]
# Obtener la lista de archivos en la carpeta
file_list = os.listdir(folder_path)

# Filtrar los archivos que terminan en ".errorlog"
errorlog_files = [file for file in file_list if file.endswith(extension)]

# Ordenar los archivos por fecha de modificación
errorlog_files.sort(key=lambda x: os.path.getmtime(os.path.join(folder_path, x)))

# Verificar si el archivo de registro ya existe
if os.path.exists(output_file):
    # Leer el contenido del archivo de registro existente
    with open(output_file, 'r') as infile:
        existing_logs = infile.readlines()
else:
    existing_logs = []

# Obtener los registros existentes como una lista de cadenas
existing_logs = [log.strip() for log in existing_logs]

# Abrir el archivo de salida en modo de escritura
with open(output_file, 'w') as outfile:
    # Escribir los registros existentes en el archivo de salida
    outfile.write('\n'.join(existing_logs))
    outfile.write('\n')

    # Iterar sobre los archivos .errorlog
    for file_name in errorlog_files:
        file_path = os.path.join(folder_path, file_name)
        
        # Obtener la fecha de modificación del archivo
        file_timestamp = os.path.getmtime(file_path)
        # Convertir la fecha de tiempo en una cadena legible
        file_date = time.ctime(file_timestamp)
        
        # Verificar si el registro ya existe en los registros existentes
        if file_date + ' ' + cliente + ' ' + file_name not in existing_logs:
            # Escribir la fecha y el nombre del archivo en el archivo de salida
            outfile.write(file_date + ' ' + cliente + ' ' + file_name)
            outfile.write('\n')
