import os
import filecmp
from pathlib import Path

# Iconos para los mensajes
ICON_OK = "✅"
ICON_ERROR = "❌"
ICON_FILE = "📁"
ICON_INFO = "⚠️"
ICON_PROGRESS = "🔄"

def normalizar_ruta(ruta):
    """Normaliza las rutas eliminando barras finales y normalizando separadores"""
    ruta = ruta.rstrip('\\/')
    # Manejo especial para rutas de unidad como "Z:"
    if len(ruta) == 2 and ruta[1] == ':':
        ruta += '\\'  # Añade barra para rutas de unidad como "Z:"
    return str(Path(ruta))

def es_archivo_sistema(nombre):
    """Determina si un archivo debe ser ignorado por ser del sistema"""
    archivos_ignorar = {
        'Thumbs.db', 
        'desktop.ini',
        '.DS_Store',
        '~$*'  # Archivos temporales de Office
    }
    return any(nombre.lower() == pat.lower() or 
               nombre.startswith('~$') for pat in archivos_ignorar)

def comparar_carpetas_contenido(carpeta1, carpeta2, archivo_salida):
    # Normalizar las rutas
    carpeta1 = normalizar_ruta(carpeta1)
    carpeta2 = normalizar_ruta(carpeta2)
    
    with open(archivo_salida, 'w', encoding='utf-8') as f:
        f.write(f"{ICON_FOLDER} COMPARACIÓN DE CARPETAS - SOLO DIFERENCIAS\n{'='*40}\n")
        f.write(f"{ICON_FOLDER} CARPETA PRINCIPAL: {carpeta1}\n")
        f.write(f"CARPETA COMPARADA: {carpeta2}\n\n")
        f.write("NOTA: Se ignoran archivos del sistema (Thumbs.db, desktop.ini, etc.)\n\n")
        
        dcmp = filecmp.dircmp(carpeta1, carpeta2)
        
        def tiene_diferencias(dcmp):
            """Determina si hay diferencias en esta carpeta o sus subcarpetas"""
            left_filtered = [f for f in dcmp.left_only if not es_archivo_sistema(f)]
            right_filtered = [f for f in dcmp.right_only if not es_archivo_sistema(f)]
            diff_filtered = [f for f in dcmp.diff_files if not es_archivo_sistema(f)]
            
            return (left_filtered or right_filtered or diff_filtered or 
                    any(tiene_diferencias(sub_dcmp) for sub_dcmp in dcmp.subdirs.values()))
        
        def reportar_diferencias(dcmp, ruta_relativa=''):
            """Reporta solo carpetas con diferencias"""
            # Determinar si hay diferencias en esta carpeta
            diferencias = False
            
            # Archivos solo en carpeta1 (filtrados)
            left_filtered = [f for f in dcmp.left_only if not es_archivo_sistema(f)]
            if left_filtered:
                for nombre in sorted(left_filtered):
                    ruta = Path(dcmp.left)/nombre
                    if ruta.is_file():
                        if not diferencias:
                            f.write(f"\nCARPETA: {ruta_relativa or 'Raíz'}\n")
                            diferencias = True
                        f.write(f"- [FALTA EN {Path(dcmp.right).name}] {nombre}\n")
            
            # Archivos solo en carpeta2 (filtrados)
            right_filtered = [f for f in dcmp.right_only if not es_archivo_sistema(f)]
            if right_filtered:
                for nombre in sorted(right_filtered):
                    ruta = Path(dcmp.right)/nombre
                    if ruta.is_file():
                        if not diferencias:
                            f.write(f"\nCARPETA: {ruta_relativa or 'Raíz'}\n")
                            diferencias = True
                        f.write(f"- [FALTA EN {Path(dcmp.left).name}] {nombre}\n")
            
            # Archivos con mismo nombre pero diferente contenido (filtrados)
            diff_filtered = [f for f in dcmp.diff_files if not es_archivo_sistema(f)]
            if diff_filtered:
                if not diferencias:
                    f.write(f"\nCARPETA: {ruta_relativa or 'Raíz'}\n")
                    diferencias = True
                for nombre in sorted(diff_filtered):
                    f.write(f"- [CONTENIDO DIFERENTE] {nombre}\n")
            
            # Procesar subcarpetas recursivamente
            for subdir, sub_dcmp in sorted(dcmp.subdirs.items()):
                nueva_ruta = f"{ruta_relativa}/{subdir}" if ruta_relativa else subdir
                reportar_diferencias(sub_dcmp, nueva_ruta)
        
        # Solo procesar si hay diferencias
        if tiene_diferencias(dcmp):
            reportar_diferencias(dcmp)
        else:
            f.write("\nNo se encontraron diferencias relevantes entre las carpetas\n")
        
        # Resumen estadístico (excluyendo archivos del sistema)
        total_left = sum(1 for _ in Path(carpeta1).rglob('*') 
                    if _.is_file() and not es_archivo_sistema(_.name))
        total_right = sum(1 for _ in Path(carpeta2).rglob('*') 
                     if _.is_file() and not es_archivo_sistema(_.name))
        f.write(f"\n{'='*40}\nRESUMEN (excluyendo archivos del sistema):\n")
        f.write(f"- Total archivos en {Path(carpeta1).name}: {total_left}\n")
        f.write(f"- Total archivos en {Path(carpeta2).name}: {total_right}\n")
        f.write(f"- Diferencia {total_right}-{total_left}\n")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) != 4:
        print(f"{ICON_INFO} Uso: python compara.py <carpeta1> <carpeta2> <archivo_salida>")
        print('Ejemplo: python compara.py "Z:" "E:\\carpeta comparación" resultado.txt')
        sys.exit(1)
    
    carpeta1 = sys.argv[1]
    carpeta2 = sys.argv[2]
    archivo_salida = sys.argv[3]
    
    try:
        carpeta1 = normalizar_ruta(carpeta1)
        if not os.path.isdir(carpeta1):
            print(f"{ICON_ERROR} Error: No se encuentra la carpeta {carpeta1}")
            sys.exit(1)
        
        carpeta2 = normalizar_ruta(carpeta2)
        if not os.path.isdir(carpeta2):
            print(f"{ICON_ERROR} Error: No se encuentra la carpeta {carpeta2}")
            sys.exit(1)
        
        comparar_carpetas_contenido(carpeta1, carpeta2, archivo_salida)
        print(f"{ICON_OK} Comparación completada. Resultados guardados en {archivo_salida}")
    
    except Exception as e:
        print(f"{ICON_ERROR} Error inesperado: {str(e)}")
        sys.exit(1)