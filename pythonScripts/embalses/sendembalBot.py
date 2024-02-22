import os
import requests
from bs4 import BeautifulSoup
import argparse
import re
from telegram import Bot
import schedule
import time
from datetime import datetime

###################################################
#                                                 #
# MAPA DE EMBALSES                                #
#                                                 #
###################################################
with open('idsembalses', 'r') as file:
        # Token del bot de Telegram
        bot_token = file.readline().strip()
        # ID del chat de Telegram donde deseas enviar el mensaje
        bot_chatID = file.readline().strip()

def bot_send_text(bot_message):
    send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?chat_id=' + bot_chatID + '&parse_mode=Markdown&text=' + bot_message
    response = requests.get(send_text)
    return response

def bot_send_img(urlImage):
    send_photo= 'https://api.telegram.org/bot'+ bot_token + '/sendPhoto?chat_id='+ bot_chatID +'&photo=' + urlImage
    response = requests.get(send_photo)
    return response

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

#https://www.embalses.net/provincia-31-cuenca.html
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
    
    # Busca todos los elementos con la clase 'FilaSeccion'
    fila_secciones = soup.select('.FilaSeccion')

    for fila_seccion in fila_secciones:
        campo = fila_seccion.select_one('.Campo').text.strip()
        resultados = fila_seccion.select('.Resultado')

        if "Agua embalsada" in campo:
            r['agua_embalsada'] = resultados[0].text.strip()
            r['agua_embalsada_per'] = resultados[1].text.strip()
            fecha = campo
        elif "Variacion semana Anterior" in campo:
            r['variacion_semana_anterior'] = resultados[0].text.strip()
            r['variacion_semana_anterior_per'] = resultados[1].text.strip()
        elif "Misma Semana (2023)" in campo:
            r['misma_semana_2023'] = resultados[0].text.strip()
            r['misma_semana_2023_per'] = resultados[1].text.strip()
        elif "Misma Semana (Med. 10 AÃ±os)" in campo:
            r['misma_semana_media_10'] = resultados[0].text.strip()
            r['misma_semana_media_10_per'] = resultados[1].text.strip()

    return r

if __name__ == '__main__':
    result = fetch_embalses()

    # ANSI codes in PowerShell
    BHRED  = '\x1b[1;91m'
    BGREEN = '\x1b[1;92m'
    CRESET = '\033[0m'

    diff= float(result.get('agua_embalsada_per', '')) - float(result.get('misma_semana_2023_per', ''))
    diffStr = "{:.2f}".format(diff)
    color= BGREEN if diff >= 0 else BHRED

    diff2= float(result.get('agua_embalsada_per', '')) - float(result.get('misma_semana_media_10_per', ''))
    diffStr2 = "{:.2f}".format(diff2)
    color2= BGREEN if diff2 >= 0 else BHRED

    print(url)
    print(f"{fecha} {result['agua_embalsada']:>3} hm³ {result.get('agua_embalsada_per', ''):>5} %")
    print(f"Variacion semana Anterior:   {result['variacion_semana_anterior']:>3} hm³ {result.get('variacion_semana_anterior_per', ''):>5} %")
    print(f"Misma Semana (2023):         {result['misma_semana_2023']:>3} hm³ {result.get('misma_semana_2023_per', ''):>5} % {color} {diffStr:>3} % {CRESET}")
    print(f"Misma Semana (Med. 10 Años): {result['misma_semana_media_10']:>3} hm³ {result.get('misma_semana_media_10_per', ''):>5} % {color2} {diffStr2:>3} % {CRESET}")

    # Enviar el mensaje a Telegram

    message2 = f"{url}\n"
    message =f"{fecha}  {result['agua_embalsada']:>3} hm³ {result.get('agua_embalsada_per', ''):>5} %\n"
    message +=f"Variacion semana Anterior:         {result['variacion_semana_anterior']:>3} hm³  {result.get('variacion_semana_anterior_per', ''):>5} %\n"
    message +=f"Misma Semana (2023):                 {result['misma_semana_2023']:>3} hm³ {result.get('misma_semana_2023_per', ''):>5} % {diffStr:>3} %\n"
    message +=f"Misma Semana (Med. 10 Años): {result['misma_semana_media_10']:>3} hm³ {result.get('misma_semana_media_10_per', ''):>5} % {diffStr2:>3} %\n"
    #print(message)

    test_bot = bot_send_text(provincia.upper())
    test_bot = bot_send_text(message)
    test_bot = bot_send_img(imgUrl)
    test_bot = bot_send_text(message2)