import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext

# Estructura: "MNEMONICO": ("TIPO", opcode, funct/null)
INSTRUCTIONS = {
    # TIPO R
    "ADD": ("R", 0, 0x20), "SUB": ("R", 0, 0x22), "AND": ("R", 0, 0x24),
    "OR":  ("R", 0, 0x25), "SLT": ("R", 0, 0x2A),
    # TIPO I
    "ADDI": ("I", 0x08, None), "ANDI": ("I", 0x0C, None), "ORI": ("I", 0x0D, None),
    "XORI": ("I", 0x0E, None), "SLTI": ("I", 0x0A, None), "BEQ": ("I_BEQ", 0x04, None),
    # TIPO I MEMORIA
    "LW": ("I_MEM", 0x23, None), "SW": ("I_MEM", 0x2B, None),
    # TIPO J
    "J": ("J", 0x02, None),
    # NOP (Pseudo-instrucción para burbujas)
    "NOP": ("NOP", None, None)
}

def parse_register(reg_str):
    reg_str = reg_str.strip().replace('$', '').replace(',', '')
    try: return int(reg_str)
    except ValueError: raise ValueError(f"Registro inválido: {reg_str}")

def to_binary(num, bits):
    if num < 0: num = (1 << bits) + num
    mask = (1 << bits) - 1
    return f'{num & mask:0{bits}b}'

def decode_instruction(line):
    try:
        parts = line.strip().replace(',', ' ').split()
        # Ignorar líneas vacías o comentarios
        parts = [p for p in parts if p]
        if not parts or parts[0].startswith('#') or parts[0].startswith('//'): return None 

        mnemonic = parts[0].upper()
        if mnemonic not in INSTRUCTIONS: raise ValueError(f"Instrucción desconocida: {mnemonic}")
            
        inst_type, opcode_val, funct_val = INSTRUCTIONS[mnemonic]
        
        # CASO ESPECIAL NOP
        if inst_type == "NOP":
            return "00000000"

        opcode_bin = to_binary(opcode_val, 6)
        bin_32 = ""

        if inst_type == "R": 
            if len(parts) != 4: raise ValueError("Faltan operandos R")
            rd, rs, rt = parse_register(parts[1]), parse_register(parts[2]), parse_register(parts[3])
            bin_32 = opcode_bin + to_binary(rs, 5) + to_binary(rt, 5) + to_binary(rd, 5) + "00000" + to_binary(funct_val, 6)

        elif inst_type == "I":
            if len(parts) != 4: raise ValueError("Faltan operandos I")
            rt, rs, imm = parse_register(parts[1]), parse_register(parts[2]), int(parts[3])
            bin_32 = opcode_bin + to_binary(rs, 5) + to_binary(rt, 5) + to_binary(imm, 16)
                      
        elif inst_type == "I_BEQ":
            if len(parts) != 4: raise ValueError("Faltan operandos BEQ")
            rs, rt, offset = parse_register(parts[1]), parse_register(parts[2]), int(parts[3])
            bin_32 = opcode_bin + to_binary(rs, 5) + to_binary(rt, 5) + to_binary(offset, 16)

        elif inst_type == "I_MEM":
            if len(parts) != 3: raise ValueError("Formato incorrecto Memoria")
            rt = parse_register(parts[1])
            mem_part = parts[2].replace(')', '')
            offset_str, rs_str = mem_part.split('(')
            bin_32 = opcode_bin + to_binary(parse_register(rs_str), 5) + to_binary(rt, 5) + to_binary(int(offset_str), 16)

        elif inst_type == "J":
            if len(parts) != 2: raise ValueError("Falta target J")
            bin_32 = opcode_bin + to_binary(int(parts[1]), 26)

        # Convertir binario a entero y luego a string HEXADECIMAL de 8 dígitos
        val_int = int(bin_32, 2)
        return f"{val_int:08X}"

    except Exception as e: raise ValueError(f"Error en '{line}': {str(e)}")

# --- GUI ---
def browse_file():
    filepath = filedialog.askopenfilename(filetypes=[("Text Files", "*.txt"), ("All Files", "*.*")])
    if not filepath: return
    txt_editor.delete("1.0", tk.END)
    with open(filepath, 'r') as f: txt_editor.insert("1.0", f.read())

def process_and_save():
    input_text = txt_editor.get("1.0", tk.END)
    lines = input_text.strip().split('\n')
    hex_lines = []
    
    try:
        for line in lines:
            hex_str = decode_instruction(line)
            if hex_str: 
                hex_lines.append(hex_str)
        
        if not hex_lines:
            messagebox.showwarning("Aviso", "No hay instrucciones válidas para guardar.")
            return
            
        save_path = filedialog.asksaveasfilename(defaultextension=".txt", filetypes=[("Text File", "*.txt")])
        if save_path:
            # Guardar como TEXTO plano, una instrucción por línea
            with open(save_path, 'w') as f:
                f.write('\n'.join(hex_lines))
            messagebox.showinfo("Éxito", f"Archivo generado en: {save_path}")
            
    except ValueError as e: messagebox.showerror("Error", str(e))

# --- Configuración de Ventana ---
window = tk.Tk()
window.title("Decodificador MIPS - Proyecto Final")
window.geometry("600x450")

frame_top = tk.Frame(window)
frame_top.pack(pady=10)

tk.Button(frame_top, text="Cargar Archivo", command=browse_file).pack(side=tk.LEFT, padx=5)
tk.Button(frame_top, text="Decodificar y Guardar", command=process_and_save, bg="#ddffdd").pack(side=tk.LEFT, padx=5)
tk.Button(frame_top, text="Limpiar", command=lambda: txt_editor.delete("1.0", tk.END)).pack(side=tk.LEFT, padx=5)

tk.Label(window, text="Soporta: R-Type, I-Type, J-Type, NOP", fg="blue").pack()

txt_editor = scrolledtext.ScrolledText(window, width=70, height=20)
txt_editor.pack(padx=10, pady=10)

window.mainloop()