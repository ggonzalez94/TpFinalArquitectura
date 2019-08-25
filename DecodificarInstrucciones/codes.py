Opcodes = {
    "lb": "100000",
    "lh": "100001",
    "lw": "100011",
    "lbu": "100100",
    "lhu": "100101",
    "lwu": "100111",
    "sb": "101000",
    "sh": "101001",
    "sw": "101011",
    "addi": "001000",
    "andi": "001100",
    "ori": "001101",
    "xori": "001110",
    "lui": "001111",
    "slti": "001010",
    "beq": "000100",
    "bne": "000101",
    "j": "000010",
    "jal": "000011"
}

FunctCodes = {
    "sll" : "000000",
    "srl" : "000010",
    "sra" : "000011",
    "sllv" : "000100",
    "srlv" : "000110",
    "srav" : "000111",
    "addu" : "100001",
    "subu" : "100011",
    "and" : "100100",
    "or" : "100101",
    "xor" : "100110",
    "nor" : "100111",
    "slt" : "101010",
    "jr"  : "001000",
    "jalr" : "001001"
}


tipoR = ("sll","srl","sra","sllv","srlv",
    "srav","addu","subu","and","or","xor","nor","slt","jr","jalr")
tipoI = ("lb","lh","lw","lbu","lhu","lwu","sb","sh","sw",
        "addi","andi","ori","xori","lui","slti","beq","bne")
tipoJ = ("j","jal")

