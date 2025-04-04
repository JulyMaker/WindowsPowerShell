import os
import sys
import subprocess
import yt_dlp
from urllib.parse import quote
from typing import Union, List, Dict
from tqdm import tqdm

"""
# Formato fichero entrada
Artista1|Canción 1
Artista1|Canción 2
Artista2|https://youtube.com/watch?v=...  # URL directa
Artista3|Canción con nombre largo
"""


def entrada(rutaArchivo: str) -> Dict[str, List[str]]:
    """
    Lee un archivo de entrada con el formato:
    Artista|Canción o URL
    y devuelve un diccionario {artista: [canciones/urls]}
    """
    cancionesPorArtista = {}
    
    try:
        with open(rutaArchivo, 'r', encoding='utf-8') as f:
            for linea in f:
                linea = linea.strip()
                if not linea or linea.startswith('#'):
                    continue
                
                # Separar artista y canción/url
                if '|' in linea:
                    artista, cancion = linea.split('|', 1)
                else:
                    artista = "Varios"
                    cancion = linea
                
                if artista not in cancionesPorArtista:
                    cancionesPorArtista[artista] = []
                cancionesPorArtista[artista].append(cancion.strip())
                
        return cancionesPorArtista
    
    except Exception as e:
        print(f"❌ Error al leer el archivo: {e}")
        sys.exit(1)

def es_youtube(texto: str) -> bool:
    """Verifica si el texto es una URL de YouTube"""
    return any(dominio in texto.lower() for dominio in ['youtube.com', 'youtu.be'])

def buscar_urls(
    canciones: Union[str, List[str]],
    max_resultados: int = 1,
) -> Dict[str, List[str]]:
    """
    Busca enlaces de YouTube para una o múltiples canciones.
    Devuelve un diccionario {canción: [enlaces]}
    """
    if isinstance(canciones, str):
        canciones = [canciones]
    
    ydl_opts = {
        'quiet': True,
        'extract_flat': True,
        'force_generic_extractor': True,
        'default_search': f'ytsearch{max_resultados}:',
        'skip_download': True,
    }
    
    resultados = {}
    
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        for cancion in canciones:
            if es_youtube(cancion):
                resultados[cancion] = [cancion]
                print(f"🔗 URL directa: {cancion} ✅")
                continue

            try:
                 # ¡Clave! Formato de búsqueda especial
                query = f"ytsearch{max_resultados}:{cancion}"
                info = ydl.extract_info(query, download=False)

                enlaces = []

                if info and 'entries' in info:
                    enlaces = [
                        f"https://youtube.com/watch?v={entry['id']}" 
                        for entry in info['entries'] 
                        if entry and 'id' in entry
                    ]
                
                print(f"🔍 {cancion} → Encontrados: {len(enlaces)} ✅")
                resultados[cancion] = enlaces[:max_resultados]
                
            except Exception as e:
                print(f"🔍 {cancion} → {str(e)} ❌")
                resultados[cancion] = None
    
    return resultados

def descargar_musica(url: str, cancion: str, artista: str, carpeta: str ="Mi_Musica"):
    """Descarga una canción y la guarda en carpeta del artista"""
    try:
        # Crear carpeta del artista si no existe
        carpeta_artista = os.path.join(carpeta, artista)
        os.makedirs(carpeta_artista, exist_ok=True)

        class ProgressBar(tqdm):
            def update_to(self, d):
                if d['status'] == 'downloading':
                    self.total = d.get('total_bytes') or d.get('total_bytes_estimate')
                    self.update(d['downloaded_bytes'] - self.n)

        opciones = {
            'format' : 'bestaudio/best',
            'outtmpl': f'{carpeta_artista}/%(title)s.%(ext)s',
            'postprocessors': [{
                'key': 'FFmpegExtractAudio',
                'preferredcodec': 'mp3',
                'preferredquality': '192',
            }],
            #'progress_hooks': [ProgressBar(desc=cancion[:20]).update_to],
            'quiet': True,
        }
        print(f"\n📥 Descargando: '{artista} - {cancion}'...")

        with yt_dlp.YoutubeDL(opciones) as ydl:
            ydl.download([url])
            print(f"✅ Descarga completada: {artista}/{cancion}")
    except Exception as e:
        print(f"Ocurrio un error : {e}")

def main():
    print("🎵 Generador de listas aleatorias y descargador de canciones 🎵")
    print("="*60)
    
   # Solicitar archivo de entrada
    archivo_entrada = input("\nIntroduce la ruta del archivo con las canciones: ").strip()

    if not os.path.exists(archivo_entrada):
        print("❌ El archivo no existe")
        sys.exit(1)

    # Leer y procesar archivo
    canciones_por_artista = entrada(archivo_entrada)

    # Buscar URLs para todas las canciones
    todas_canciones = {}
    for artista, canciones in canciones_por_artista.items():
        print(f"\n🔎 Buscando canciones de {artista}...")
        resultados = buscar_urls(canciones)
        todas_canciones[artista] = resultados

    # Preguntar por descargas
    descargar = input("\n¿Quieres descargar estas canciones? (s/n): ").strip().lower()
    
    if descargar == "s":
        print("\n📥 Iniciando descargas (puede tardar varios minutos)...\n")
        
        for artista, canciones in todas_canciones.items():
            for cancion, urls in canciones.items():
                if not urls:
                    continue
        
                for url in urls:
                    nombre_cancion = cancion if not es_youtube(cancion) else "Desde_URL"
                    descargar_musica(url, nombre_cancion, artista)

        print("\n🎉 ¡Proceso completado! Canciones guardadas en:")
        print(f"📂 {os.path.abspath('Mi_Musica')}")
    else:
        print("\n🚀 URLs generadas. Puedes copiarlas para descargar manualmente.")

if __name__ == "__main__":
    # Verificar si yt-dlp está instalado
    try:
        subprocess.run(["yt-dlp", "--version"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        main()
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Error: yt-dlp no está instalado. Instálalo con:")
        print("pip install yt-dlp --upgrade")
        sys.exit(1)