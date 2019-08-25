from codes import *
from funciones import *

def decodificarInstruccion(instruccion):
    try:
        lista = instruccion.split(" ")
        codigo = lista[0].lower()
        operacion = lista[1].lower()
        if(codigo in tipoR):
            return convertirInstruccionTipoR(codigo,operacion)
        if(codigo in tipoI):
            return convertirInstruccionTipoI(codigo,operacion)
        if(codigo in tipoJ):
            return convertirInstruccionTipoJ(codigo,operacion)
        return "No se reconoce la instruccion"

    except:
        return "Instruccion mal formateada"
        
print ("Iniciando")
try:
    f = open("instrucciones.txt", "r")
    for line in f:
        print(decodificarInstruccion(line.strip()))
    f.close()
except:
    print("El archivo no existe o no se pudo leer.")
