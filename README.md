

# CNN Accelerator Building Block in Verilog

This project implements a **small but realistic hardware block** used inside modern **CNN accelerators** .

The design performs the core operations that every CNN accelerator relies on:

1. **3×3 Convolution using fixed-point MAC units**
2. **ReLU activation**
3. **2×2 Max-pooling**
4. **Multiple filters processed in parallel**
5. **Line buffer + window buffer dataflow**, which is standard in real hardware accelerators

The aim is not to build a full CNN, but to show how the **main building block** of a CNN accelerator is built from scratch in Verilog.

This project is written in simple, modular Verilog so that anyone can understand the underlying concepts without needing an FPGA board.

---

# 1. What This Project Actually Does

This design behaves like the **core computational engine** inside AI hardware chips.

In all real CNN accelerators, the most important component is the **convolution engine**, which continuously takes small windows (like 3×3) of an image and performs:

```
MAC (Multiply + Accumulate)
Activation
Pooling
```

This project implements:

✔ 3×3 convolution (same as CNNs)
✔ learned weights loaded from memory
✔ ReLU activation
✔ 2×2 max-pooling
✔ multi-filter parallel processing

This is exactly one **CNN layer block**, packaged the same way that real accelerators use internally.

---

# 2. Why This Is a CNN Accelerator Building Block

Traditional image processing uses fixed filters (like Sobel or Gaussian).

CNN accelerators use:

* **Learned 3×3 filters**
* **Sliding-window hardware**
* **MAC arrays**
* **Activation units**
* **Pooling units**
* **Weight memories**
* **Dataflow controllers**

This project includes all of these.

This is the reason it qualifies as a **CNN accelerator building block**, not just basic image filtering.

---

# 3. Repository Structure

```
src/         → Verilog RTL files  
tb/          → Testbenches  
data/        → Image, weights, golden reference  
scripts/     → Python golden model  
docs/        → Notes and diagrams  
README.md    → This document
```

---

# 4. File-by-File Explanation (Very Simple Language)

## 4.1 `cnn_params.vh`

Stores all common settings:

* image size
* bit-width
* number of filters
* fractional bits

This keeps the whole design clean and configurable.

---

## 4.2 `mac_3x3.v`

Implements the core **Multiply–Accumulate (MAC)** operation.

It takes:

* 9 pixels
* 9 weights

And performs the sum of all multiplications.

This is the most important logic inside every CNN accelerator, because convolution is just repeated MAC operations.

---

## 4.3 `relu.v`

Implements the ReLU activation used in neural networks:

```
If value < 0 → output = 0  
Else → output = value
```

ReLU makes the model nonlinear.
This is a key step in CNNs.

---

## 4.4 `maxpool_2x2.v`

Performs **2×2 max-pooling**, which is used in CNNs to:

* reduce feature-map size
* keep only the strongest activations

This module takes 4 numbers and outputs the largest.

---

## 4.5 `line_buffer.v`

Stores the previous two rows of the image.

Why?

A 3×3 window needs 3 rows.
But incoming pixels arrive one-by-one.

Real CNN accelerators **always use line buffers**.

---

## 4.6 `window_buffer.v`

This module forms the actual **3×3 sliding window**.

It uses the output of the line buffer and shifts pixel values to create the full 3×3 block.

This is exactly how real hardware extracts pixels for convolution.

---

## 4.7 `conv_core.v`

Connects:

* line buffer
* window buffer
* MAC units
* weight memory

Produces convolution outputs for multiple filters.

This module is the “mini CNN engine.”

It uses the same dataflow as actual accelerator IP cores.

---

## 4.8 `weight_mem.v`

Stores the learned CNN weights (kernels).

CNN training happens on a computer, and the resulting 3×3 kernels are loaded into hardware.

This memory simulates that step.

---

## 4.9 `feature_mem_in.v`

Stores the input image in hex format.

Loaded using `$readmemh`.

---

## 4.10 `feature_mem_out.v`

Stores the final processed feature map after:

* convolution
* ReLU
* pooling

---

## 4.11 `controller.v`

A simple finite-state machine that coordinates everything.

Similar to real NPU/TPU controllers, it tells:

* when to read a pixel
* when a window is valid
* when MAC should compute
* when pooling should start
* when the entire layer is finished

---

## 4.12 `cnn_top.v`

The top-level module that connects all components together.

Think of this as the “chip” that contains:

* memory
* convolution engine
* activation unit
* pooling unit
* FSM controller

This is the module you simulate.

---

# 5. Testbenches

## `tb_mac_3x3.v`

Tests if the MAC unit multiplies and adds correctly.

## `tb_line_window.v`

Checks if the 3×3 window moves across the image correctly.

## `tb_cnn_top.v`

Runs the entire CNN building block from start to finish:

* loads image
* loads weights
* performs convolution
* applies ReLU
* does pooling
* writes final output

---

# 6. Python Golden Model

The Python script in `/scripts` performs the same operations as the Verilog design:

* convolution
* ReLU
* pooling

This lets you verify that hardware output matches software output.

Golden models are widely used in real chip design.

---

# 7. How to Run (Vivado)

1. Open Vivado
2. Add files from `src/` and `tb/`
3. Set top module:

   ```
   tb_cnn_top
   ```
4. Run simulation
5. Watch the output feature map in the simulation logs or memory dump

---

# 8. What This Block Can Do

✔ Perform 3×3 convolution
✔ Apply ReLU
✔ Apply max-pooling
✔ Process multiple filters
✔ Fully simulate a CNN layer
✔ Use real CNN-trained weights
✔ Represent the core of CNN accelerators (TPU/NPU style)

---

# 9. What This Block Cannot Do

❌ Train a neural network
❌ Perform full deep learning inference
❌ Handle large resolutions efficiently
❌ Include deeper layers (unless extended)
❌ Replace a complete AI accelerator


---

# 10. Future Extensions

* Add padding and stride
* Add BatchNorm
* Add multiple layers
* Add streaming input/output
* Add a larger MAC array
* Implement on FPGA
* Build a memory scheduler
* Add quantization-aware processing

Each of these makes it closer to a real NPU.

---

# 11. Conclusion

This project is a clean and understandable implementation of the **core building block used inside real CNN accelerators** such as:

* Google TPU
* NVIDIA NVDLA
* AMD/Xilinx DPU
* Intel Movidius NPU

It recreates the internal dataflow of a CNN engine using:

* sliding windows
* MAC arrays
* CNN weights
* activation
* pooling
* controller FSM

