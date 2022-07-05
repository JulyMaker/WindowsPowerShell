import os, sys, re
import pathlib
import time

if(len(sys.argv) > 1):
  path = pathlib.Path(sys.argv[1])
else:
  path = pathlib.Path('.')

files = [file.name for file in path.iterdir() if file.is_file()]

print ("Copying files:       ", end="")

progress = 0
progresBar = "_"
count = 0
errorF = []

for file in files:
    count = count + 1
    pathFile = os.path.join(path, file)

    m_ti = time.ctime( os.path.getmtime( pathFile )) 
    timeobj = time.strptime(m_ti) 
  
    date = time.strftime("%Y-%m-%d", timeobj)

    if(file.lower().endswith('.jpg')):
      folderName = os.path.join(date, "images")
    else:
      folderName = os.path.join(date, "videos")

    destpath = os.path.join(path, folderName)
    os.makedirs(destpath, exist_ok=True)

    try :
      os.rename(pathFile, os.path.join(destpath, file))
    except OSError as error:
      errorF.append(file)

    progress = (count*100)/len(files)
    num = "{:.2f}".format(progress)
    progresBar= progresBar + "_"

    retroceso = "\b" * (4 + len(progresBar))

    print (retroceso + progresBar, end="")
    print ( num + "%", end="")

print("")
print("OK")

for name in errorF:
	print (name + " ya existe.")