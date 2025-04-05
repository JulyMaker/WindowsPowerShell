import os
import re
import shutil
from pathlib import Path

def limpiar_nombre(nombre):
    """Elimina caracteres especiales y normaliza el nombre"""
    nombre_limpio = re.sub(r'[\\/*?:"<>|\[\]]', '', nombre)
    return nombre_limpio.strip()

def extraer_info_archivo(nombre_archivo):
    """Extrae temporada y episodio del nombre del archivo"""
    # Solo analiza el nombre del archivo (no la ruta completa)
    nombre_archivo = Path(nombre_archivo).name
    
    # Primero eliminamos resoluciones para evitar falsos positivos
    nombre_sin_resolucion = re.sub(r'\d{3,4}p', '', nombre_archivo, flags=re.IGNORECASE)
    
    # Patrones mejorados (ordenados por especificidad)
    patrones = [
        r"Cap[íi]tulo[ _](\d{1,2})[ _\-]?[xX\-]?[ _]?(\d{1,2})",  # Capítulo 1x02
        r"Cap[\.]?[ _](\d{1})(\d{2})",                            # Cap.102
        r"[Ss](\d{1,2})[\.\-_]?[Ee](\d{1,2})",                    # S01E01, S1-E01
        r"(\d{1,2})[xX](\d{1,2})",                                # 1x01
        r"Temporada[ _](\d{1,2})[ _\-]?[Cc]ap[íi]tulo[ _](\d{1,2})", # Temporada 1 Capítulo 2
        r"\[(\d{1,2})\-(\d{1,2})\]",                               # [01-01]
        r"(\d{1,2})(\d{2})(?!p)",                                  # 102 (pero no 720p)
    ]
    
    for patron in patrones:
        match = re.search(patron, nombre_sin_resolucion)
        if match:
            temporada = match.group(1).zfill(2)
            episodio = match.group(2).zfill(2)
            return temporada, episodio
    
    # Intento alternativo para nombres como "Silo - 1x01 - Episodio"
    match = re.search(r'(\d{1,2})x(\d{1,2})', nombre_sin_resolucion)
    if match:
        return match.group(1).zfill(2), match.group(2).zfill(2)
    
    return None, None

def procesar_archivos(directorio, nombre_serie):
    """Busca y renombra archivos de video en el directorio y subcarpetas"""
    nombre_serie = limpiar_nombre(nombre_serie)
    extensiones_video = ('.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.m4v')
    
    directorio_principal = Path(directorio).resolve()
    archivos_video = []
    
    for root, _, files in os.walk(directorio):
        for file in files:
            if file.lower().endswith(extensiones_video):
                archivos_video.append(Path(root) / file)
    
    if not archivos_video:
        print("❌ No se encontraron archivos de video en el directorio.")
        return
    
    print(f"\n🔎 Encontrados {len(archivos_video)} archivos de video:")
    
    for archivo_original in archivos_video:
        temporada, episodio = extraer_info_archivo(archivo_original.name)
        
        if not temporada or not episodio:
            print(f"\n❌ No se pudo detectar temporada/episodio en: {archivo_original.name}")
            continue
        
        extension = archivo_original.suffix.lower()
        nuevo_nombre = f"{nombre_serie} {temporada}x{episodio}{extension}"
        
        if archivo_original.parent.resolve() != directorio_principal:
            archivo_destino = directorio_principal / nuevo_nombre
            accion = "🚀 Movido y renombrado"
        else:
            archivo_destino = archivo_original.parent / nuevo_nombre
            accion = "🚀 Renombrado"
        
        if archivo_destino.exists():
            print(f"\n⚠️ Archivo ya existe, omitiendo: {nuevo_nombre}")
            continue
        
        try:
            shutil.move(str(archivo_original), str(archivo_destino))
            print(f"{accion}: {archivo_original.name} -> {nuevo_nombre}")
        except Exception as e:
            print(f"\n❌ Error al procesar {archivo_original}: {str(e)}")

if __name__ == "__main__":
    print("=== Renombrador de Archivos de Series ===")
    
    directorio = input("\n📂 Introduce el directorio (deja vacío para usar el actual): ").strip()
    if not directorio:
        directorio = os.getcwd()
    
    if not os.path.isdir(directorio):
        print(f"\n❌ Error: El directorio '{directorio}' no existe.")
        exit(1)
    
    nombre_serie = input("\n🎬 Introduce el nombre de la serie: ").strip()
    if not nombre_serie:
        print("\n❌ Error: Debes introducir un nombre de serie.")
        exit(1)
    
    print(f"\n📥 Procesando archivos en: {directorio}")
    procesar_archivos(directorio, nombre_serie)
    
    print("\n✅ Proceso completado.")