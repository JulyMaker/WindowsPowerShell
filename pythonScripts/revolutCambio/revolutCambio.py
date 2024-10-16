import requests
from bs4 import BeautifulSoup

url = "https://www.google.com/finance/quote/EUR-USD"

response = requests.get(url)
if response.status_code == 200:
    soup = BeautifulSoup(response.text, 'html.parser')
    exchange_rate = soup.find('div', class_='YMlKec fxKbKc').text

    print(f"El tipo de cambio actual de EUR a USD es: {exchange_rate}")
else:
    print(f"Error al obtener el tipo de cambio: {response.status_code}")
