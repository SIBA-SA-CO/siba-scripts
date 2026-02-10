# Generador de Logs Nagra – SIBA
Compatibilidad Python 2 y Python 3

Este proyecto contiene DOS versiones del mismo script.
Ambas hacen exactamente lo mismo, pero existen debido a limitaciones del
servidor productivo que aún utiliza Python 2.6.6.

---

## ¿Qué hace el script?

El proceso:

1. Lee una carpeta con archivos generados por Nagra.
2. Filtra únicamente los archivos que:
   - tengan la extensión indicada (.failed, .error, .errorlog)
   - contengan la fecha actual en el nombre → SIBA_YYYYMMDD
3. Ordena los archivos por fecha de modificación.
4. Extrae información:
   - Para `.error` y `.errorlog` → guarda el contenido del archivo.
   - Para `.failed` → obtiene el valor dentro del tag `<ChannelId>`.
5. Evita duplicados comparando contra lo ya escrito en el log.
6. Agrega nuevas líneas al final del archivo destino.

---

## Parámetros de ejecución

El script recibe 4 argumentos:

1. folder_path  → Carpeta donde están los archivos
2. output_file  → Log destino
3. cliente      → Nombre del cliente (se guarda como [Cliente])
4. extension    → Extensión a procesar

Ejemplo Linux:
python  siba-claroco-nagra-s6-generador-log.py "/home/Failed" "/var/log/siba.log" "NagraAndroid" ".failed"


---

## ¿Por qué existen dos versiones?

Durante el despliegue se encontró que el servidor usa:

Python 2.6.6

El script original estaba hecho en Python 3, lo que produjo errores de:

- Sintaxis (f-strings)
- Uso de encoding en open()
- Manejo de texto Unicode

Para evitar modificar el servidor productivo, se decidió mantener:

✔ una versión legacy (Python 2)  
✔ una versión moderna (Python 3)

---

## Diferencias técnicas entre versiones

### Python 3
Usa características modernas:

- f"{variable}"
- open(..., encoding="utf-8")

Más legible, más seguro con caracteres especiales.

---

### Python 2
No soporta nada de eso.

Se reemplazó por:

- "%s" % variable
- open() sin encoding

para que pueda ejecutarse en el sistema actual sin instalar nada adicional.

---

## ¿Cuál usar?

### En servidores antiguos
Usar:

python>2.6.6>siba-claroco-nagra-s6-generador-log.py

### En equipos modernos / pruebas locales
Usar:

python>siba-claroco-nagra-s6-generador-log.py

---

## Notas importantes

Python 2 está oficialmente descontinuado desde 2020.
Esta versión existe únicamente por compatibilidad con infraestructura legacy.

Si en algún momento el servidor se actualiza, la versión recomendada
a mantener es la de Python 3.