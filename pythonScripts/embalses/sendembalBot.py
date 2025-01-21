import os
import requests
from bs4 import BeautifulSoup
import argparse
import re
from telegram import Bot
import schedule
import time
from datetime import datetime, timedelta

###################################################
#                                                 #
#       TELEGRAM BOT                              #
#                                                 #
###################################################

with open('idsembalses', 'r') as file:
        # Token del bot de Telegram
        bot_token = file.readline().strip()
        # ID del chat de Telegram donde deseas enviar el mensaje
        bot_chatID = file.readline().strip()

def bot_send_text(message):
    send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?chat_id=' + bot_chatID + '&disable_web_page_preview=true&parse_mode=Markdown&text=' + message
    response = requests.get(send_text)
    return response

def bot_send_imge(urlImage, message):
    send_photo= 'https://api.telegram.org/bot'+ bot_token + '/sendPhoto?chat_id='+ bot_chatID +'&photo='+ urlImage +'&parse_mode=Markdown&caption='+ message
    response = requests.get(send_photo)
    return response

###################################################
#                                                 #
# MAPA DE EMBALSES                                #
#                                                 #
###################################################

def provinciaCodeAndName(urlName):
    try:
        match = re.search(r'provincia-(\d+)-([a-zA-Z]+)', urlName)
        if match:
            provinciaCode = match.group(1)
            provinciaName = match.group(2).capitalize()  # Convierte la primera letra en mayúscula
            return provinciaCode, provinciaName
        else:
            return None, None
    except requests.exceptions.RequestException as e:
        print(f"No se pudo obtener información: {e}")
        return None, None


def provinciaMap(url):
    try:
        response = requests.get(url)
        response.raise_for_status()
        soup = BeautifulSoup(response.content, 'html.parser')
        maProvincias = {}

        provinciasLinks = soup.find_all('a', href=lambda href: href and "provincia-" in href)

        for link in provinciasLinks:
            provinciaLink = link['href']
            codigo, nombre = provinciaCodeAndName(provinciaLink)
            if codigo is not None and nombre is not None:
                maProvincias[nombre.lower()] = codigo

        return maProvincias
    except requests.exceptions.RequestException as e:
        print(f"No se pudo obtener la página: {e}")
        return None


###################################################
#                                                 #
#           Info Embalse Provincia                #
#                                                 #
###################################################

parser = argparse.ArgumentParser(description='Scrape data from embalses.net.')
parser.add_argument('--url', help='URL to scrape')
parser.add_argument('--provincia', help='provincia name')
#parser.add_argument('--img', action='store_true', help='graphic url')
args = parser.parse_args()

url = 'https://www.embalses.net/provincia-45-madrid.html'

provincia= "MADRID"
if args.url or args.provincia:
    if not args.provincia:
        url = args.url
    else:
        if args.provincia != 'madrid':
            urlProv = "https://www.embalses.net/provincias.php"
            mapProv = provinciaMap(urlProv)
            url = 'https://www.embalses.net/provincia-{}-{}.html'.format(mapProv[args.provincia.lower()], args.provincia)
            provincia=args.provincia

fecha = ""
imgUrl= ""

def fetch_embalses():
    global fecha, imgUrl
    r = {}
    cnt = 0
    last_year = datetime.now().year - 1

    try:
        response = requests.get(url)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')

    except requests.exceptions.RequestException as e:
        cnt += 1
        if cnt < 2:
            fetch_embalses()
        else:
            print("Not found")
            exit(1)

    if not soup:
        print("Not found")
        exit(1)

    meta_tag = soup.find('meta', {'property': 'og:image'})
        
    if meta_tag:
        imgUrl = meta_tag.get('content')

        #imageResponse = requests.get(imgUrl)
        #
        #if imageResponse.status_code == 200:
        #    with open("graphic.png", "wb") as file:
        #        file.write(imageResponse.content)
    
    fila_secciones = soup.select('.FilaSeccion')

    for fila_seccion in fila_secciones:
        campo = fila_seccion.select_one('.Campo').text.strip()
        resultados = fila_seccion.select('.Resultado')

        if "Agua embalsada" in campo:
            r['agua_embalsada'] = resultados[0].text.strip()
            r['agua_embalsada_per'] = resultados[1].text.strip()
            fecha = campo
        elif "VariaciÃ³n semana Anterior" in campo:
            r['variacion_semana_anterior'] = resultados[0].text.strip()
            r['variacion_semana_anterior_per'] = resultados[1].text.strip()
        elif f"Misma Semana ({last_year})" in campo:
            print("Pase por aqui")
            r[f'misma_semana_{last_year}'] = resultados[0].text.strip()
            r[f'misma_semana_{last_year}_per'] = resultados[1].text.strip()
        elif "Misma Semana (Med. 10 AÃ±os)" in campo:
            r['misma_semana_media_10'] = resultados[0].text.strip()
            r['misma_semana_media_10_per'] = resultados[1].text.strip()

    return r

def extract_date_from_string(fecha_str):
    start_idx = fecha_str.find('(')
    end_idx = fecha_str.find(')')
    if start_idx != -1 and end_idx != -1:
        fecha_str = fecha_str[start_idx+1:end_idx]
        try:
            return datetime.strptime(fecha_str, "%d-%m-%Y")
        except ValueError:
            print(f"Error al convertir la fecha: {fecha_str}")
    return None

def check_and_fetch():
    required_fields = ['agua_embalsada', 'agua_embalsada_per', 'variacion_semana_anterior', 'variacion_semana_anterior_per', f'misma_semana_{datetime.now().year - 1}', f'misma_semana_{datetime.now().year - 1}_per', 'misma_semana_media_10', 'misma_semana_media_10_per']
    
    MAX_RETRIES = 7
    retries = 0

    while True:
      result = fetch_embalses()

      if result is None or not all(field in result for field in required_fields):
        print("Faltan datos, reintentando en 10 segundos...")
        time.sleep(10)
        retries += 1
        if retries >= MAX_RETRIES:
            raise RuntimeError("Máximo de reintentos alcanzado al obtener datos.")
        continue
  
      print(fecha)
      fecha_obj = extract_date_from_string(fecha)
      two_days_ago = datetime.now() - timedelta(days=2)
  
      now = datetime.now()
      start_of_week = now - timedelta(days=now.weekday())
      start_of_week = start_of_week.replace(hour=0, minute=0, second=0, microsecond=0) # Lunes a las 00:00:00
      end_of_week = start_of_week + timedelta(days=6, hours=23, minutes=59, seconds=59)  # Domingo a las 23:59:59

      if fecha_obj and not (start_of_week <= fecha_obj <= end_of_week):
            print("La fecha no está dentro de esta semana. Reintentando en 1 hora...")
            time.sleep(3600)
            retries += 1
            if retries >= MAX_RETRIES:
                raise RuntimeError("Máximo de reintentos alcanzado al verificar la fecha.")
            continue
  
      return result
    
if __name__ == '__main__':
    result = check_and_fetch()
    last_year = datetime.now().year - 1

    # ANSI codes in PowerShell
    BHRED  = '\x1b[1;91m'
    BGREEN = '\x1b[1;92m'
    CRESET = '\033[0m'

    diff= float(result.get('agua_embalsada_per', '')) - float(result.get(f'misma_semana_{last_year}_per', ''))
    diffStr = "{:.2f}".format(diff)
    color= BGREEN if diff >= 0 else BHRED

    diff2= float(result['agua_embalsada_per']) - float(result['misma_semana_media_10_per'])
    diffStr2 = "{:.2f}".format(diff2)
    color2= BGREEN if diff2 >= 0 else BHRED

    print(url)
    print(f"{fecha} {result['agua_embalsada']:>3} hm³ {result.get('agua_embalsada_per', ''):>5} %")
    print(f"Variacion semana Anterior:   {result['variacion_semana_anterior']:>3} hm³ {result.get('variacion_semana_anterior_per', ''):>5} %")
    print(f"Misma Semana ({last_year}):         {result[f'misma_semana_{last_year}']:>3} hm³ {result.get(f'misma_semana_{last_year}_per', ''):>5} % {color} {diffStr:>3} % {CRESET}")
    print(f"Misma Semana (Med. 10 Años): {result['misma_semana_media_10']:>3} hm³ {result.get('misma_semana_media_10_per', ''):>5} % {color2} {diffStr2:>3} % {CRESET}")

    # Send Telegram message

    message  =f"{provincia.upper()} \n"
    message +=f"```cpp\n"
    message +=f"{fecha} {result['agua_embalsada']} hm³ {result.get('agua_embalsada_per', '')}%\n"
    message +=f"Variacion semana Anterior:   {result['variacion_semana_anterior']:>3} hm³ {result['variacion_semana_anterior_per']:>5}%\n"
    message +=f"Misma Semana ({last_year}):         {result[f'misma_semana_{last_year}']} hm³ {result.get(f'misma_semana_{last_year}_per', '')}% {diffStr:>5}%\n"
    message +=f"Misma Semana (Med. 10 Años): {result['misma_semana_media_10']} hm³ {result.get('misma_semana_media_10_per', '')}% {diffStr2:>5}%"
    message +=f"```"
    message +=f"{url}"

    #print(message)

    #test_bot = bot_send_text(message)
    test_bot = bot_send_imge(imgUrl,message)