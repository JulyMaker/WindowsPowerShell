import os, sys, re
import pathlib

path = pathlib.Path('.')
limitValue = 34

if(len(sys.argv) > 2):
  path = pathlib.Path(sys.argv[1])
  limitValue = int(sys.argv[2])
elif(len(sys.argv) > 1):
  path = pathlib.Path(sys.argv[1])

files = [file.name for file in path.iterdir() if file.is_file() and file.name.lower().endswith('.srt')]

for file in files:
  print ("Testeando "+ file)

  regex = "(\d+)ms"
  count = 0
  total = 0

  f = open(os.path.join(path, file))
  try:
    for linea in f:
      m = re.search(regex, linea)    
      if(m):
        total = total + 1
        if( int(m.group(1)) > limitValue):
          count = count + 1
  finally:
    f.close()

  if(count == 0):
     print ("  SIN PERDIDA !!! ")
  else:
    print ("   Hemos perdido " + str(count) + " frames de " + str(total))
