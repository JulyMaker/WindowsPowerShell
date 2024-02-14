import requests
from bs4 import BeautifulSoup
from telegram import Bot
import schedule
import time
from datetime import datetime


def bot_send_text(bot_message):
    with open('ids', 'r') as file:
        # Token del bot de Telegram
        bot_token = file.readline().strip()
        # ID del chat de Telegram donde deseas enviar el mensaje
        bot_chatID = file.readline().strip()

    send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?chat_id=' + bot_chatID + '&parse_mode=Markdown&text=' + bot_message
    response = requests.get(send_text)

    return response

def report():
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"Hora: {current_time}")

    # URL de la página
    url = "https://shop.theglamping.com/shared/frames/frame/180/es"
    
    # Realizar la solicitud HTTP
    response = requests.get(url)
    
    # Verificar si la solicitud fue exitosa
    if response.status_code == 200:
        # Obtener el contenido HTML de la página
        html_content = response.content
    
        # Crear un objeto BeautifulSoup
        soup = BeautifulSoup(html_content, 'html.parser')
    
        # Encontrar el ComboBox por su ID
        combobox = soup.find('select', {'id': 'form_tent_0'})
    
        if combobox:
            # Verificar si la opción deseada está presente en el ComboBox sin la palabra '[SOLDOT]'
            option_found = any('Tienda CONFORT 4 pax' in option.text and '[SOLDOUT]' not in option.text for option in combobox.find_all('option'))
    
            if option_found:
                # Enviar mensaje de Telegram
                message = f"¡Alerta! 'Tienda CONFORT 4 pax' está disponible' en {url}."
                print(message)
                test_bot = bot_send_text(message)
            else:
                print("'Tienda CONFORT 4 pax [SOLDOUT]'")
    else:
        print(f"Error al realizar la solicitud. Código de estado: {response.status_code}")


if __name__ == '__main__':
    report()
