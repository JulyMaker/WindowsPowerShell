import logging
from telegram import Update
from telegram.ext import filters, MessageHandler, ApplicationBuilder, CommandHandler, ContextTypes
import subprocess

ruta_script = "sendrevolutCambioBot.py"
with open('idscambio', 'r') as file:
        bot_token = file.readline().strip()
        bot_chatID = file.readline().strip()

valid_currencies = {"USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY", "SEK", "NZD"} # Can add more

logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)

async def pregunta(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(chat_id=bot_chatID, text="Soy tu bot, pregunta lo que quieras")

async def echo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(chat_id=bot_chatID, text="Esto no es un comando")

async def cambio(update: Update, context: ContextTypes.DEFAULT_TYPE):    
    args = context.args

    if len(args) < 2:
        await context.bot.send_message(chat_id=bot_chatID, text="Por favor, introduce moneda1, moneda 2 y treshold.")
        return
    
    money1 = args[0] if len(args) > 0 else "EUR"
    money2 = args[1] if len(args) > 1 else "USD"
    treshold = args[2] if len(args) > 2 else "0"  
    
    if money1 not in valid_currencies or money2 not in valid_currencies:
        await context.bot.send_message(chat_id=bot_chatID, text=f"Error: {money1} o {money2} no son códigos de moneda válidos.")
        return
        
    subprocess.run(["python", ruta_script, "--from_currency", money1, "--to_currency", money2, "--threshold", treshold])

async def unknown(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(chat_id=bot_chatID, text="Sorry, I didn't understand that command.")

if __name__ == '__main__':
    application = ApplicationBuilder().token(bot_token).build()

    pregunta_handler = CommandHandler('pregunta', pregunta)
    cambio_handler = CommandHandler('cambio', cambio)
    #echo_handler  = MessageHandler(filters.TEXT & (~filters.COMMAND), echo)
    unknown_handler = MessageHandler(filters.COMMAND, unknown)
    
    application.add_handler(pregunta_handler)
    application.add_handler(cambio_handler)
    application.add_handler(unknown_handler)

    application.run_polling()
    