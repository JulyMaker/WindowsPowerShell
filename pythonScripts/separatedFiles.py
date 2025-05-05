import os, sys, re
import pathlib
import time

# Iconos para los mensajes
ICON_OK = "✅"
ICON_ERROR = "❌"
ICON_FILE = "📁"
ICON_FOLDER = "📂"
ICON_PROGRESS = "🔄"

if len(sys.argv) > 2:
    path = pathlib.Path(sys.argv[1])
    moveVideo = sys.argv[2]
elif len(sys.argv) > 1:
    path = pathlib.Path(sys.argv[1])
    moveVideo = True
else:
    path = pathlib.Path('.')
    moveVideo = True

files = [file.name for file in path.iterdir() if file.is_file()]
parent_folder_name = os.path.basename(os.path.normpath(path))

print(f"{ICON_PROGRESS} Copiando archivos:       ", end="")

progress = 0
progresBar = "_"
count = 0
errorF = []

for file in files:
    count = count + 1
    skipVideo = False
    pathFile = os.path.join(path, file)

    m_ti = time.ctime(os.path.getmtime(pathFile)) 
    timeobj = time.strptime(m_ti) 
  
    date = time.strftime("%Y-%m-%d", timeobj)

    if file.lower().endswith('.jpg'):
        folderName = os.path.join(date, f"{parent_folder_name}_images")
    else:
        if moveVideo == True:
            folderName = os.path.join(date, f"{parent_folder_name}_videos")
        else:
            skipVideo = True

    try:
        if not skipVideo:
            destpath = os.path.join(path, folderName)
            os.makedirs(destpath, exist_ok=True)
            os.rename(pathFile, os.path.join(destpath, file))
    except OSError as error:
        errorF.append(file)

    progress = (count * 100) / len(files)
    num = "{:.2f}".format(progress)
    progresBar = progresBar + "_"

    retroceso = "\b" * (4 + len(progresBar))

    print(retroceso + progresBar, end="")
    print(num + "%", end="")

print("")
print(f"{ICON_OK} Proceso completado")

if errorF:
    print(f"\n{ICON_ERROR} Archivos con errores:")
    for name in errorF:
        print(f"{ICON_FILE} {name} ya existe.")
else:
    print(f"{ICON_OK} Todos los archivos se procesaron correctamente")