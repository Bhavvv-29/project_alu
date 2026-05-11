# **Project README: Parameterized ALU Design & Verification**

## **Project Overview**
This project involves the development and rigorous functional verification of a **Parameterized Arithmetic Logic Unit (ALU)**[cite: 281, 286]. Designed as a high-performance computational core, this ALU provides a scalable architecture that allows the data width of operands and results to be easily modified to meet specific hardware requirements without redesigning the underlying logic.

## **Key Features**
* **Parameterized Scalability:** Operands (`OPA`, `OPB`), results (`RES`), and command width (`CMD`) are all scalable via Verilog parameters[cite: 288, 326].
* **Dual-Mode Functionality:** Operates as a mathematical engine in **Arithmetic Mode** (`MODE` High) or a bit-level processor in **Logical Mode** (`MODE` Low)[cite: 295, 296, 302].
* **Comprehensive Instruction Set:** Supports 28 unique operations, including signed/unsigned arithmetic, complex multi-step math (Multiply-Increment), bitwise logic gates, and advanced data rotations.
* **Fail-Safe Diagnostics:** A dedicated **ERR** flag triggers to alert the system of invalid operand configurations or out-of-range rotation parameters[cite: 309, 310].
* **Performance Optimization:** Includes a **Clock Enable (CE)** pin for power gating and uses a **3-cycle operation flow** to ensure data stability[cite: 314, 318, 474].

## **Design Architecture**
The design follows a synchronous RTL flow utilizing a system clock (`CLK`) and an **active-high asynchronous reset** (`RST`)[cite: 313, 334].



### **Input/Output Specification**
| Signal | Type | Bits | Functionality |
| :--- | :--- | :--- | :--- |
| **OPA / OPB** | Input | Parameterized | Primary data operands. |
| **MODE** | Input | 1 | High: Arithmetic operations; Low: Logical operations. |
| **CMD** | Input | Parameterized | Determines the specific operation to be performed. |
| **INP_VALID** | Input | 2 | 00: None; 01: OPA valid; 10: OPB valid; 11: Both valid. |
| **RES** | Output | 2 * Data Width | Total result of the instruction, doubled for multiplication. |
| **OFLOW / COUT**| Output | 1 | Flags for arithmetic overflow and carry-out status. |
| **G / L / E** | Output | 1 | Comparator flags: Greater than, Lesser than, and Equal to. |
| **ERR** | Output | 1 | Error flag for invalid instructions or parameters]. |

## **Timing & Working Flow**
The ALU operates as a synchronous system with a fixed latency profile[cite: 472]:
* **Cycle 1 (Input Phase):** Inputs are sampled on the rising edge of the clock and stored in internal buffers (`r_opa`, `r_opb`, etc.).
* **Cycle 2 (Operation Phase):** Internal logic processes the selected arithmetic or logical operation.
* **Cycle 3 (Output Phase):** The final response is driven onto the **RES** bus and status flags are updated for capture.
* **Note on Latency:** While standard instructions complete in the cycle following the input phase, complex instructions like **Multiply-Increment** (`4'h9`) and **Shift-Multiply** (`4'hA`) follow the full 3-cycle latency.

## **Verification Strategy**
The design was verified using a robust **Self-Checking Testbench** that utilizes a behavioral **Reference Model** (Golden Model).



* **Stimulus Generator:** Uses specialized tasks (`test_arithmetic` and `test_logical`) to drive standard and corner-case inputs.
* **Synchronization:** The testbench accounts for the 3-cycle operation latency, waiting for the required clock cycles before sampling outputs.
* **Scoreboard:** Bit-by-bit comparison is performed between the DUT and Reference Model to ensure a 100% pass rate.

## **Quality Assessment & Results**
The project achieved high-quality metrics as validated by **Questasim**]:

| Coverage Type | Achievement | Assessment |
| :--- | :--- | :--- |
| **Total Coverage** | **93.42%** | Excellent overall verification health. |
| **FSM (States/Transitions)**| **100.00%** | All 3 states and 5 transitions fully exercised. |
| **Toggles** | **100.00%** | All 186 internal signals successfully transitioned. |
| **Branches** | **96.36%** | 53 out of 55 logical paths were navigated. |
| **Statements** | **95.74%** | 90 out of 94 lines of code were triggered. |

## **Tools Used**
* **Vivado:** Used for RTL design entry, synthesis, and initial functional simulation.
* **Questa SIM:** Employed for advanced verification and comprehensive code coverage analysis.

---
**Author:** BHAVANI SHRI S 
**Project ID:** PROJECT-ALU 
