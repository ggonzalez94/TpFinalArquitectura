from codes import *

def convertirInstruccionTipoR(codigo,operacion):
    funct = FunctCodes[codigo]
    lista = operacion.split(",")
    opcode = f'{0:06b}'
    rs = f'{0:05b}'
    rt = f'{0:05b}'
    rd  = f'{0:05b}'
    shamt = f'{0:05b}'

    if(codigo in ("sll","srl","sra")): #SLL,SRL,SRA
        rd = lista[0][1:]
        rt = lista[1][1:]
        shamt = lista[2]
        return opcode + f'{0:05b}' + f'{int(rt):05b}' + f'{int(rd):05b}' + f'{int(shamt):05b}' + funct

    if(codigo in ("jr")): #JR
        rs = lista[0][1:]
        return opcode + f'{int(rs):05b}' + f'{0:16b}' + funct

    if(codigo in ("jalr")): #JALR
        rs = lista[0][1:]
        rd = lista[1][1:]
        return opcode + f'{int(rs):05b}' + f'{0:05b}' + f'{int(rd):05b}' + f'{0:05b}' + funct
    
    #Otras tipo R
    rd = lista[0][1:]
    rt = lista[1][1:]
    rs = lista[2][1:]
    return opcode + f'{int(rs):05b}' + f'{int(rt):05b}' + f'{int(rd):05b}' + f'{0:05b}' + funct

def convertirInstruccionTipoI(codigo,operacion):
    opcode = Opcodes[codigo]
    lista = operacion.split(",")
    rs = f'{0:05b}'
    rt = f'{0:05b}'
    constante  = f'{0:16b}'

    if (codigo in ("lb","lh","lw","lbu","lhu","lwu","sb","sh","sw")):
        rt = lista[0][1:]
        constante = lista[1].split("(")[0]
        rs = lista[1].split("(")[1][1:-1]
        return opcode + f'{int(rs):05b}' + f'{int(rt):05b}' + f'{int(constante):016b}'
    
    if (codigo in ("lui")):
        rt = lista[0][1:]
        constante = lista[1]
        return opcode + f'{0:05b}' + f'{int(rt):05b}' + f'{int(constante):016b}'

    rt = lista[0][1:]
    rs = lista[1][1:]
    constante = lista[2][1:]
    return opcode + f'{int(rs):05b}' + f'{int(rt):05b}' + f'{int(constante):016b}'


def convertirInstruccionTipoJ(codigo,operacion):
    valor = operacion
    opcode = Opcodes[codigo]
    return opcode + f'{int(valor):026b}'