import os
import sys

# The name of the folder that will be created from the assembler
OUTPUT_FOLDER_NAME = "Outputs"

def translateFolder(folder_in: str, folder_out:str):
    # Converts each file in folder to machine code and stores in another folder

    cwd = os.getcwd()
    folder_in = os.path.join(cwd, folder_in)
    folder_out = os.path.join(cwd, folder_out)

    # Set to check if output folder already exists
    directories = set()
    for root, dirs, files in os.walk(cwd):

        for directory in dirs:
            directories.add(directory)

        break                               # Only check root folder

    if folder_out not in directories:
        # Create folder
        try:
            os.mkdir(folder_out)
        except FileExistsError:
            print(f"Folder already exists, using: {folder_out}\n")

    
    errors = []     # Capture any errors that result from translation

    # Iterate through all files in input folder and create machine code file into output folder
    for root, dirs, files in os.walk(folder_in):
        
        for file in files:

            input_path = os.path.join(folder_in, file)

            # Create .mem machine code filename (same as assembly file name but with .mem instead of .txt)
            name, ext = os.path.splitext(file)
            name_mem = name + ".mem"
            output_path = os.path.join(folder_out, name_mem)

            translateFile(input_path, output_path, errors)

        break       # Only look in root of folder (no subdirectories)

    if len(errors) != 0:
        print(f"============================== ERRORS SUMMARY ==============================")
        counter = 0
        for error in errors:
            print(f"=={counter+1}== \t {error}")
            counter += 1
        print(f"\nTotal Errors: {counter}")
    else:
        print("Assembler terminated successfully.")

    
def translateFile(input_asm_file: str, output_machine_file: str, errors: list):
    # Read from input_file, translate to machine code and write to file of the same name
    
    asm_file = open(input_asm_file, "r")
    _, name = os.path.split(input_asm_file)       # Store input file name for error logging

    try:

        machine_file = open(output_machine_file, "x")         # "x" to create and write
    
    except FileExistsError:

        machine_file = open(output_machine_file, "w")

    line_count = 1

    # Iterate through each line in the assembly file
    for line in asm_file:

        line = line.upper()                   

        if line.find("//") != -1:
            line = line[:line.find("//")]                       # Terminate line right before comments (//) start

        words = line.split()                                    # Split line by spaces, newlines, tabs
        
        # If line is not empty, skip, and go to next line
        if len(words) != 0:
            instruction, success, error_type = translateLine(words)         # Attempt translate

            if not success:
                error = f"{name} at line: {line_count}\t{error_type}"
                errors.append(error)

            else:
                # Write the constructed binary instruction to file
                machine_file.write(instruction)
                
            machine_file.write("\n")
        
        line_count += 1

    asm_file.close()
    machine_file.close()

def translateLine(words: list) -> tuple:
    # Translates full line and returns the binary instruction

    first_word = words[0]

    opcode, i_type, success_1 = getOpcode(first_word)
    rest, success_2, error_2 = getRestOfInstruction(i_type, words)
    success = success_1 and success_2
    instruction = opcode + rest

    error_type = ""

    if not success_1:
        error_type = f"Instruction \"{first_word}\" does not exist"               # Opcode did not match instruction set
    elif error_2 == "i":
        error_type = "Invalid format for instruction"    # Formatting of instruction was invalid
    elif error_2 == "r":
        error_type = "Invalid register (R0 - R7 only)"   # Register was not between R0 and R7
    elif error_2 == "l":
        error_type = "Length of immediate does not match instruction"

    #print(f"instruction: {instruction}, final success {success}\n")

    return instruction, success, error_type


def getOpcode(word: str) -> tuple:
    # Match word to opcode and return the binary equivalent

    # Remove "," from the instruction
    if word.endswith(","):
        word = word[:-1]
    
    opcode = ""
    i_type = ""         # Instruction type (R_n, R_s, I_n, I_s, J_n, J_s)
    success = True

    match word:
        case "HALT":
            opcode = "0000"
            i_type = "H"
        case "ADD":
            opcode = "0001"
            i_type = "R_n"
        case "ADDI":
            opcode = "0010"
            i_type = "I_n"
        case "SUB":
            opcode = "0011"
            i_type = "R_n"
        case "SUBI":
            opcode = "0100"
            i_type = "I_n"
        case "AND":
            opcode = "0101"
            i_type = "R_n"
        case "OR":
            opcode = "0110"
            i_type = "R_n"
        case "NOT":
            opcode = "0111"
            i_type = "R_s_not"
        case "LSL":
            opcode = "1000"
            i_type = "R_s"
        case "LSR":
            opcode = "1001"
            i_type = "R_s"
        case "LOAD":
            opcode = "1010"
            i_type = "I_s"
        case "LOADI":
            opcode = "1011"
            i_type = "I_s"
        case "STORE":
            opcode = "1100"
            i_type = "I_s"
        case "JUMP":
            opcode = "1101"
            i_type = "J_n"
        case "BEQ":
            opcode = "1110"
            i_type = "J_s"
        case _:
            success = False

    #print(f"opcode: {opcode}, i_type: {i_type}, success: {success}\n")

    return opcode, i_type, success

def getRestOfInstruction(i_type: str, words: list) -> tuple:
    # Based on the instruction type, construct the rest of the instruction
    # Each i_type has a different way of extracting the words

    rest = ""
    success = True
    error = ""

    try:
        match i_type:
            case "R_n":
                rest += decodeRegAddress(words[1])  # Rd
                rest += decodeRegAddress(words[2])  # Rs1
                rest += decodeRegAddress(words[3])  # Rs2
                rest += "000"                       # Unused

            case "R_s":
                rest += decodeRegAddress(words[1])  # Rd
                rest += decodeRegAddress(words[2])  # Rs1
                rest += "00"                        # Unused
                
                imm = words[3]                      # imm (4 bit, for LSL, LSR)

                if len(imm) != 4:
                    success = False
                    error = "l"
                else:
                    rest += imm

            
            case "R_s_not":
                rest += decodeRegAddress(words[1])  # Rd
                rest += decodeRegAddress(words[2])  # Rs1
                rest += "000000"                    # Unused
 
            case "I_n":
                rest += decodeRegAddress(words[1])  # Rd
                rest += decodeRegAddress(words[2])  # Rs1
                imm = words[3]                      # imm (6 bit)

                if len(imm) != 6:
                    success = False
                    error = "l"
                else:
                    rest += imm

            case "I_s":
                rest += decodeRegAddress(words[1])  # Rd
                imm = words[2]                    # imm (9 bit)

                if len(imm) != 9:
                    success = False
                    error = "l"
                else:
                    rest += imm
            
            case "J_n":
                rest += "000"                       # Unused
                imm = words[1]                      # imm (9 bit) 

                if len(imm) != 9:
                    success = False
                    error = "l"
                else:
                    rest += imm
                
            case "J_s":
                rest += decodeRegAddress(words[1])  # Rs2
                rest += decodeRegAddress(words[2])  # Rs1
                imm = words[3]                      # imm (6 bit signed)

                if len(imm) != 6:
                    success = False
                    error = "l"
                else:
                    rest += imm
            
            case "H":                               # Ignores everything after opcode
                rest += "000000000000"
    
    except IndexError:
        success = False
        error = "i"
    except ValueError:
        success = False
        error = "r"

    #print(f"rest: {rest}, success: {success}\n")
    
    return rest, success, error


def decodeRegAddress(reg: str) -> str:
    # Decodes register name (ex R3) into binary address equivalent (011)

    if reg.endswith(","):
        reg = reg[:-1]

    addr = ""

    match reg:
        case "R0":
            addr = "000"
        case "R1":
            addr = "001"
        case "R2":
            addr = "010"
        case "R3":
            addr = "011"
        case "R4":
            addr = "100"
        case "R5":
            addr = "101"
        case "R6":
            addr = "110"
        case "R7":
            addr = "111"
        case _:
            raise ValueError("Invalid register.")
        
    #print(f"Reg addr: {addr}\n")

    return addr
        


if __name__ == "__main__":

    args = sys.argv

    if len(args) != 3:
        raise Exception("Need exactly 3 positional arguments: python script, assembly input folder, and machine code output folder.")
    
    input_folder = args[1]
    output_folder = args[2]

    translateFolder(input_folder, output_folder)

