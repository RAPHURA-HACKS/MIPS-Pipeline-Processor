# Procesador MIPS Pipeline de 5 Etapas + Decodificador

Este repositorio contiene el Proyecto Final para la materia de **Arquitectura de Computadoras** (CUCEI - UdeG).

## Descripción
El proyecto consiste en el diseño e implementación de un procesador basado en la arquitectura **MIPS32** utilizando la técnica de segmentación (**Pipeline**) de 5 etapas. El objetivo es ejecutar instrucciones simultáneamente para incrementar el rendimiento.

Adicionalmente, se incluye una herramienta de software (Decodificador) desarrollada en Python para convertir código ensamblador MIPS a lenguaje máquina (binario/hexadecimal) listo para cargarse en la memoria del procesador.

## Características Principales
* **Pipeline de 5 Etapas:** Fetch, Decode, Execute, Memory, Write Back.
* **Resolución de Riesgos (Hazards):** Manejo de *Data Hazards* mediante software (inserción de NOPs).
* **Set de Instrucciones Soportado:**
    * **Tipo R:** ADD, SUB, AND, OR, SLT.
    * **Tipo I:** ADDI, ANDI, ORI, XORI, SLTI, BEQ, LW, SW.
    * **Tipo J:** J (Jump).
* **Interfaz Gráfica (GUI):** Decodificador escrito en Python (Tkinter) para facilitar la programación.

## Estructura del Proyecto
El repositorio está organizado de la siguiente manera:

* **`/01_Decodificador_Python`**: Código fuente (`Nucleo.py`) y ejecutables de la herramienta de conversión ASM a Binario.
* **`/02_Procesador_Verilog`**: Código fuente en Verilog (`.v`) de todos los módulos del procesador (ALU, Unidad de Control, Memorias, Buffers, etc.).
* **`/03_Ensamblador`**: Programas de prueba en lenguaje ensamblador (`.asm`) utilizados para validar el funcionamiento.
* **`/04_Reporte_y_Simulacion`**: Evidencias de funcionamiento, capturas de onda (ModelSim) y el reporte final en PDF.

## Tecnologías Utilizadas
* **Hardware Description:** Verilog HDL
* **Simulación:** ModelSim Intel FPGA Starter Edition
* **Software:** Python 3 (Librería Tkinter)

## Autor
**Ramón Anthony Camacho Guerrero**
*Universidad de Guadalajara*
*Centro Universitario de Ciencias Exactas e Ingenierías (CUCEI)*
