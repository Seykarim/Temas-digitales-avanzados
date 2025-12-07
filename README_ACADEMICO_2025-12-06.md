# Informe Técnico–Académico  
# Proyecto Temas Digitales Avanzados – Arquitectura RISC-V y SoC  
**Fecha:** 06/12/2025  
**Autor:** Seykarim  

---

# 1. Introducción

El presente documento constituye una memoria técnica y académica del proyecto desarrollado en el curso *Temas Digitales Avanzados*, cuyo propósito fue construir, simular y analizar una arquitectura basada en RISC-V, complementada con un SoC mínimo propio y simulaciones de referencia mediante el procesador FemtoRV.  
Se buscó no solo implementar módulos digitales aislados, sino integrar una plataforma de simulación reproducible, organizada y basada en principios de diseño digital contemporáneos.

El proyecto adopta un enfoque incremental: primero se desarrolla la ALU, el banco de registros y el decodificador; luego se integran en un SoC mínimo; finalmente se compara dicho SoC con la implementación educativa FemtoRV, incluyendo su módulo multiplicador y estructura de memoria.

---

# 2. Objetivo General

Diseñar e implementar un conjunto de módulos digitales fundamentales compatibles con la arquitectura RV32I, integrarlos en un SoC mínimo y validar su funcionamiento mediante simulaciones formales, contrastando los resultados con un SoC de referencia basado en FemtoRV, bajo un flujo reproducible y documentado.

---

# 3. Objetivos Específicos

1. Implementar módulos funcionales: ALU32, RegFile32, Decoder32 y memoria Bram32.  
2. Integrar dichos módulos en un SoC básico capaz de ejecutar un flujo secuencial de instrucciones.  
3. Construir un conjunto de testbenches que verifiquen el comportamiento aislado y compuesto de los módulos.  
4. Simular el SoC local y compararlo con un SoC basado en FemtoRV.  
5. Analizar el módulo multiplicador presente en la arquitectura FemtoRV y comprender su integración en el mapa de memoria.  
6. Documentar de forma organizada, clara y técnica todo el entorno de simulación.  

---

# 4. Alcances del Proyecto

- Implementación funcional de ALU, banco de registros, decodificador y memoria RAM.  
- Construcción de un SoC mínimo (`SOC_flash`) con memoria inicializable mediante `program.mem`.  
- Simulación completa del flujo PC–instrucción–decodificador–ALU.  
- Integración y simulación del SoC FemtoRV local.  
- Simulación del SoC FemtoRV de referencia del flujo VLSI.  
- Creación de scripts automatizados que permiten ejecutar cada simulación de forma determinística.  

---

# 5. Limitaciones

- No se implementó una arquitectura pipeline de 3 o 5 etapas.  
- No se integró una unidad de control de excepciones ni CSR.  
- El SoC propio no incluye periféricos adicionales como UART, SPI o temporizadores.  
- El multiplicador no se implementó como módulo propio aislado, sino que se analizó mediante el comportamiento del SoC FemtoRV.  
- No se ejecutaron test suites oficiales de RISC-V (rv32ui, rv32mi).  

---

# 6. Arquitectura del Sistema

El diseño se organizó siguiendo una estructura modular:

1. **ALU32**: operaciones aritmético-lógicas con señales de estado.  
2. **RegFile32**: banco de 32 registros con x0 cableado a cero.  
3. **Decoder32**: extracción de campos, generación de inmediatos y señales de control.  
4. **Core32**: PC, lógica básica de flujo y conexiones con memoria.  
5. **Bram32**: memoria inicializable mediante archivo externo.  
6. **SOC_flash**: integración mínima de los componentes anteriores.  
7. **FemtoRV (local)**: SoC de referencia para comparación operativa.  
8. **FemtoRV (VLSI)**: SoC extendido usado en flujos TinyTapeout/Sky130.  

---

# 7. Descripción de los Módulos

## 7.1 ALU32
Implementa suma, resta, desplazamientos lógicos y aritméticos, comparaciones con y sin signo y operaciones lógicas. La señal `alu_op` gobierna el comportamiento, alineado con las señales emitidas por el decodificador.

## 7.2 RegFile32
Banco de registros de doble lectura y escritura síncrona.  
El registro x0 se preserva como cero, cumpliendo la especificación RISC-V.

## 7.3 Decoder32
Genera inmediatos y señales de control para los tipos de instrucción R, I, S, B, U y J. Produce señales de alto nivel necesarias para dirigir la ALU, la memoria y el flujo de programa.

## 7.4 Bram32
Memoria RAM parametrizable, usada como memoria de instrucciones. Permite simulaciones reproducibles mediante `$readmemh`.

## 7.5 Core32 y SOC_flash
Core32 implementa un flujo secuencial de ejecución basado en PC.  
SOC_flash conecta este núcleo con la memoria e interfaces simples, permitiendo observar:

- Evolución del PC  
- Instrucciones leídas  
- Señales de control derivadas  

---

# 8. Procesador FemtoRV: Integración y análisis

## 8.1 FemtoRV local
El módulo `femto` permite simular un procesador RISC-V funcional, con periféricos básicos como LEDS y memoria SPI emulada. El testbench `femto_TB.v` genera un reloj, controla el reset y permite examinar el comportamiento interno mediante GTKWave.

## 8.2 FemtoRV VLSI de referencia
Este flujo replica el SoC orientado a síntesis para TinyTapeout/Sky130. Incluye memoria QSPI, controladores, periferia mínima y un entorno de prueba completo.  
La simulación genera trazas que permiten observar el comportamiento del core durante ejecución.

## 8.3 El módulo multiplicador en FemtoRV
El multiplicador es un periférico mapeado en memoria. Su funcionamiento se evalúa indirectamente en las simulaciones del SoC, donde el núcleo ejecuta instrucciones que interactúan con él.  
Este periférico sirve como referencia para integrar futuras extensiones al SoC propio.

---

# 9. Scripts de Simulación

Los scripts se encuentran en la carpeta `scripts/`:

- `run_alu32.sh`
- `run_regfile32.sh`
- `run_decoder32.sh`
- `run_soc_new.sh`
- `run_femto_soc_local.sh`
- `run_femtorv_soc_ref.sh`

Todos pueden ejecutarse desde la raíz del proyecto:


---

# 10. Resultados de Simulación

Las simulaciones generaron archivos VCD que pueden abrirse con GTKWave.  
Los resultados muestran:

- Transiciones correctas del PC.  
- Decodificación coherente de instrucciones.  
- Operaciones ALU validadas.  
- Lectura y escritura correcta en RegFile32.  
- Ejecución secuencial en SOC_flash.  
- Actividad observable en LEDS para el FemtoRV local.  
- Comportamiento alineado con el FemtoRV VLSI de referencia.  

---

# 11. Trabajo Futuro

- Implementar pipeline de 5 etapas.  
- Añadir un módulo multiplicador propio.  
- Integrar periféricos UART y SPI reales.  
- Implementar CSR e interrupciones.  
- Ejecutar test suite RV32I completo.  
- Sintetizar el SoC propio en un flujo OpenLane.  

---

# 12. Conclusiones

El proyecto desarrolló una arquitectura coherente con RV32I, construida desde sus módulos fundamentales hasta un SoC mínimo funcional. La comparación con el FemtoRV local y de referencia permitió validar decisiones de diseño y demostrar que el entorno completo es reproducible y técnicamente sólido.

EOD

echo "README académico creado en: $DEST"
EOF

chmod +x generar_readme_academico_temas2025.sh

