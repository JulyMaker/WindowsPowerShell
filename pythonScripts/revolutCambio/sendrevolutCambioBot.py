import os
import requests
from bs4 import BeautifulSoup
import argparse
from telegram import Bot

with open('idscambio', 'r') as file:
    bot_token = file.readline().strip()
    bot_chatID = file.readline().strip()

def bot_send_text(chat_id, message):
    send_text = 'https://api.telegram.org/bot' + bot_token + '/sendMessage?chat_id=' + chat_id + '&disable_web_page_preview=true&parse_mode=Markdown&text=' + message
    response = requests.get(send_text)
    return response

def get_exchange_rate(from_currency="EUR", to_currency="USD"):
    url = f"https://www.google.com/finance/quote/{from_currency}-{to_currency}"
    response = requests.get(url)

    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        exchange_rate = soup.find('div', class_='YMlKec fxKbKc').text
        exchange_rate = exchange_rate.replace(",", "")
        return float(exchange_rate)
    else:
        print(f"Error al obtener el tipo de cambio: {response.status_code}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Obtener el tipo de cambio entre dos monedas.")
    parser.add_argument('--chatID', type=str, default='0', help='ChatId (default: botChatId)')
    parser.add_argument('--from_currency', type=str, default='EUR', help='Moneda de origen (default: EUR)')
    parser.add_argument('--to_currency', type=str, default='USD', help='Moneda de destino (default: EUR)')
    parser.add_argument('--threshold', type=float, default=0.09, help='Valor umbral para enviar alerta (default: 1.09)')
    args = parser.parse_args()

    exchange_rate = get_exchange_rate(args.from_currency, args.to_currency)
    if exchange_rate and exchange_rate > args.threshold:
        message = f"El tipo de cambio actual de {args.from_currency} a {args.to_currency} es: {exchange_rate}"

        chatID = bot_chatID if args.chatID == '0' else args.chatID
        test_bot = bot_send_text(chatID, message)

        print(f"Mensaje enviado: {message}")
    else:
        print(f"El tipo de cambio es menor que el umbral ({args.threshold}), no se envió mensaje.")


if __name__ == "__main__":
    main()

#python revolutCambio.py --from_currency EUR --to_currency GBP --threshold 0.85