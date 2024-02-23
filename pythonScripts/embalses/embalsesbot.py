import logging
from telegram import Update
from telegram.ext import filters, MessageHandler, ApplicationBuilder, CommandHandler, ContextTypes
import subprocess

ruta_script = "sendembalBot.py"
with open('idsembalses', 'r') as file:
        # Token del bot de Telegram
        bot_token = file.readline().strip()
        # ID del chat de Telegram donde deseas enviar el mensaje
        bot_chatID = file.readline().strip()

logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)

async def pregunta(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(chat_id=bot_chatID, text="Soy tu bot, pregunta lo que quieras")

async def echo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(chat_id=bot_chatID, text="Esto no es un comando")

async def embalse(update: Update, context: ContextTypes.DEFAULT_TYPE):
    text_caps = ' '.join(context.args).upper()
    #resultado= subprocess.run(["python", ruta_script, "--provincia", text_caps, "--img"], capture_output=True, text=True)
    #imgUrl= resultado.stdout
    #await context.bot.send_message(chat_id=bot_chatID, text=text_caps)
    #await context.bot.send_document(chat_id=bot_chatID, document='graphic.png')
    #await context.bot.send_document(chat_id=bot_chatID, document=imgUrl)
    subprocess.run(["python", ruta_script, "--provincia", text_caps ])
    

async def unknown(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await context.bot.send_message(chat_id=bot_chatID, text="Sorry, I didn't understand that command.")

if __name__ == '__main__':
    application = ApplicationBuilder().token(bot_token).build()

    pregunta_handler = CommandHandler('pregunta', pregunta)
    embalse_handler = CommandHandler('embalse', embalse)
    embalses_handler = CommandHandler('embalses', embalse)
    #echo_handler  = MessageHandler(filters.TEXT & (~filters.COMMAND), echo)
    unknown_handler = MessageHandler(filters.COMMAND, unknown)
    
    application.add_handler(pregunta_handler)
    application.add_handler(embalse_handler)
    application.add_handler(embalses_handler)
    #application.add_handler(echo_handler)
    application.add_handler(unknown_handler)

    application.run_polling()
    