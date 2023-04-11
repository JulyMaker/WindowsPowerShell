import os, sys, re
import pathlib
import time

from tqdm import tqdm
from tqdm.auto import trange

if(len(sys.argv) > 2):
  path = pathlib.Path(sys.argv[1])
  moveVideo= sys.argv[2]
elif(len(sys.argv) > 1):
  path = pathlib.Path(sys.argv[1])
  moveVideo = True
else:
  path = pathlib.Path('.')
  moveVideo = True

files = [file.name for file in path.iterdir() if file.is_file()]
errorF = []

for i in trange(len(files), desc="Copying files ", ncols=100):
    skipVideo = False
    file= files[i] 
    pathFile = os.path.join(path, file)

    m_ti = time.ctime( os.path.getmtime( pathFile )) 
    timeobj = time.strptime(m_ti) 
  
    date = time.strftime("%Y-%m-%d", timeobj)

    if(file.lower().endswith('.jpg')):
      folderName = os.path.join(date, "images")
    else:
      if(moveVideo == True):
        folderName = os.path.join(date, "videos")
      else:
        skipVideo = True

    try :
      if(not skipVideo):
        destpath = os.path.join(path, folderName)
        os.makedirs(destpath, exist_ok=True)
        os.rename(pathFile, os.path.join(destpath, file))
    except OSError as error:
      errorF.append(file)

    #tqdm.write(pathFile+ " ")

print("")
print("OK")

for name in errorF:
	print (name + " ya existe.")