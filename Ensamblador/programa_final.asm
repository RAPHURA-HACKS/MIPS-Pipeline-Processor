# Proyecto Final Arquitectura de Computadoras
# Programa: Prueba de Riesgos de Datos y Memoria
# Autor: Ramón Anthony Camacho Guerrero

# 1. Cargar valor 5 en el registro temporal $10
ADDI $10, $0, 5

# NOPs para evitar Data Hazards (Burbujas)
ADD $0, $0, $0
ADD $0, $0, $0

# 2. Guardar el valor 5 (de $10) en Memoria RAM, dirección 20
SW $10, 20($0)

# NOPs de espera
ADD $0, $0, $0
ADD $0, $0, $0

# 3. Leer el valor de Memoria RAM (dir 20) y guardarlo en $11
LW $11, 20($0)

# NOPs de espera
ADD $0, $0, $0
ADD $0, $0, $0

# 4. Operación Aritmética: Sumar $10 + $11 y guardar en $12
# Esperado: 5 + 5 = 10 (0x0A)
ADD $12, $10, $11