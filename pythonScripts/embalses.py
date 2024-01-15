import os
import requests
from bs4 import BeautifulSoup
import argparse

#https://www.embalses.net/provincia-31-cuenca.html
parser = argparse.ArgumentParser(description='Scrape data from embalses.net.')
parser.add_argument('--url', default='https://www.embalses.net/provincia-45-madrid.html', help='URL to scrape')
args = parser.parse_args()
url = args.url

def fetch_embalses():
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

    # Busca todos los elementos con la clase 'FilaSeccion'
    fila_secciones = soup.select('.FilaSeccion')

    for fila_seccion in fila_secciones:
        campo = fila_seccion.select_one('.Campo').text.strip()
        resultados = fila_seccion.select('.Resultado')
        
        if "Agua embalsada" in campo:
            r['agua_embalsada'] = resultados[0].text.strip()
            r['agua_embalsada_per'] = resultados[1].text.strip()
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

result = fetch_embalses()

print(url)
print(f"Agua embalsada:              {result['agua_embalsada']:>3} hm³ {result.get('agua_embalsada_per', ''):>5} %")
print(f"Variacion semana Anterior:   {result['variacion_semana_anterior']:>3} hm³ {result.get('variacion_semana_anterior_per', ''):>5} %")
print(f"Misma Semana (2023):         {result['misma_semana_2023']:>3} hm³ {result.get('misma_semana_2023_per', ''):>5} %")
print(f"Misma Semana (Med. 10 Años): {result['misma_semana_media_10']:>3} hm³ {result.get('misma_semana_media_10_per', ''):>5} %")