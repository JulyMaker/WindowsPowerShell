import os
import sys
import colorama
from colorama import Fore, Back, Style
from math import pow

# Fore: BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE, RESET.
# Back: BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE, RESET.
# Style: DIM, NORMAL, BRIGHT, RESET_ALL
# RED = '\033[31m'   # mode 31 = red forground

colorama.init()

try:
  dir = sys.argv[1]
except IndexError:
  sys.exit("Must provide an argunmet.")

dir_size = 0
prefixes = ['', 'Kilo', 'Mega', 'Giga']
fsizedicr = {
    f'{prefix}bytes'.capitalize(): pow(1024, -i) for i, prefix in enumerate(prefixes)
}

for(path, dirs, files) in os.walk(dir):
	for file in files:
		filename = os.path.join(path,file)
		dir_size += os.path.getsize(filename)

fsizeList = [str(round(fsizedicr[key] * dir_size, 2)) + " " + key for key in fsizedicr]

if dir_size == 0: print ("File empty")
else:
	for units in sorted(fsizeList)[::-1]:
		print ("Folder Size: " + Fore.GREEN + units + Fore.WHITE)

print ("")