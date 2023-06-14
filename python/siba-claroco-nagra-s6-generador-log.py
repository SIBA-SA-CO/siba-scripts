# -*- coding: utf-8 -*-

import os
import time
import sys
import re

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
        error_content = ''
        channelId = ''

        if(extension == ".errorlog" or extension == ".error"):
            # Obtener el error
            with open(file_path, 'r') as error_file:
                error_content = error_file.read().replace('\n', ' ')

            # Obtener la fecha de modificación del archivo
            file_timestamp = os.path.getmtime(file_path)
            # Convertir la fecha de tiempo en una cadena legible
            file_date = time.ctime(file_timestamp)
            
            registro = file_date + ' ' + cliente + ' ' + file_name + ' ' + error_content
            # Verificar si el registro ya existe en los registros existentes
            if registro.strip() not in existing_logs:
                # Escribir la fecha y el nombre del archivo en el archivo de salida
                outfile.write(file_date + ' ' + cliente + ' ' + file_name + ' ' + error_content)
                outfile.write('\n')

        elif(extension == ".failed"):
            # Obtiene el ChannelId 
            with open(file_path, 'r') as channelId_file:
                chanelid_content = channelId_file.read()
            channelId = re.search(r'<ChannelId>(.*?)</ChannelId>', chanelid_content).group(1)
            
            # Obtener la fecha de modificación del archivo
            file_timestamp = os.path.getmtime(file_path)
            # Convertir la fecha de tiempo en una cadena legible
            file_date = time.ctime(file_timestamp)
            
            registro = file_date + ' ' + cliente + ' ' + file_name + ': ' + channelId
            # Verificar si el registro ya existe en los registros existentes
            if registro.strip() not in existing_logs:
                # Escribir la fecha y el nombre del archivo en el archivo de salida
                outfile.write(file_date + ' ' + cliente + ' ' + file_name + ': ' + channelId)
                outfile.write('\n')