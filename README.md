

# 🧠 CNN Accelerator Building Block (Verilog HDL)

This project implements a **hardware building block used inside real Neural Network Accelerators** .
It recreates, in simple Verilog HDL, the **core operations of a CNN layer**:

* **3×3 convolution** using fixed-point MAC units
* **ReLU activation**
* **2×2 max pooling**
* **Multiple learned filters**
* **Sliding-window hardware (line + window buffers)**
* **A small controller to coordinate the dataflow**

---

# 📌 1. Why This Project Exists

Understanding how CNNs run on hardware (not Python) is one of the most important skills in modern digital design.
This project shows, step by step, **how a CNN layer is implemented in hardware**, including:

* reading pixels like a stream
* forming sliding 3×3 windows
* performing multiply-accumulate (MAC) operations
* applying activation functions
* performing pooling
* controlling the flow with a simple FSM

Everything is designed so even beginners to hardware or CNNs can understand it.

---

# 🚀 2. Quick Start (Run This First)

## **Vivado Simulation**

1. Open **Vivado → “Run Simulation”**
2. Add all files from:

   * `src/`
   * `tb/`
3. Set top module:

   ```
   tb_cnn_top
   ```
4. Run the simulation
5. Observe:

   * 3×3 windows forming
   * convolution results
   * ReLU
   * pooling
   * final feature map stored in output memory

---

## **Verify using Python (Golden Model)**

This allows you to check whether the Verilog output is correct.

1. Go to `scripts/`
2. Run:

   ```bash
   python3 golden_cnn.py
   ```
3. The script will generate:

   ```
   golden_conv_out.hex
   golden_pooled_out.hex
   ```
4. Compare these with Verilog output files.

---

# 🗂️ 3. Repository Structure

```
cnn_accelerator_verilog/
│
├── src/                → All Verilog HDL modules
├── tb/                 → Testbenches
├── data/               → Input image, weights, golden outputs
├── scripts/            → Python golden model for verification
├── docs/               → Notes / Diagrams
└── README.md           → This file
```

---

# 🧱 4. Architecture Overview (Simple Explanation)

Here is the processing pipeline your hardware implements:

```
Input Image
    ↓
Line Buffer  → remembers previous 2 rows
    ↓
Window Buffer → forms 3×3 block at each pixel shift
    ↓
MAC Array (multiple filters) → performs 3×3 convolution
    ↓
ReLU → sets negative values to 0
    ↓
2×2 Max Pooling → reduces size
    ↓
Output Feature Map
```

This is exactly how **real CNN accelerators** (Google TPU, NVIDIA NVDLA, Xilinx DPU) compute feature maps internally.

---

# 🔍 5. Module-by-Module Explanation

---

## **5.1 `cnn_params.vh`**

Stores all configuration values:

* bit-width of data
* how many fractional bits (fixed-point)
* image size
* number of filters

This makes the entire project easy to modify.

---

## **5.2 `mac_3x3.v`**

This is the **brain** of the CNN accelerator.

It takes:

* 9 pixels
* 9 weights

And calculates:

```
output = p0*w0 + p1*w1 + ... + p8*w8
```

This is exactly what convolution is.

---

## **5.3 `relu.v`**

Implements:

```
if (x < 0) 
    x = 0;
```

ReLU is what makes neural networks nonlinear.

---

## **5.4 `maxpool_2x2.v`**

From every 2×2 block:

```
take the largest value
```

Pooling shrinks the image while keeping strong features.

---

## **5.5 `line_buffer.v`**

When doing convolution, you need **3 rows at a time**,
but pixels arrive **one per clock cycle**.

So this module **stores the previous 2 rows**,
exactly like real image/video FPGA pipelines.

---

## **5.6 `window_buffer.v`**

Takes the 3 rows and produces a **3×3 sliding window**.

This is the hardware equivalent of:

```python
window = image[i:i+3, j:j+3]
```

---

## **5.7 `conv_core.v`**

This is the **mini CNN engine**.

It connects:

* line buffer
* window buffer
* MAC units
* weight memory

Outputs convolution results for multiple filters.

---

## **5.8 `weight_mem.v`**

Stores CNN filter weights in hex format.

These weights would normally come from a trained model.

---

## **5.9 `feature_mem_in.v`**

Stores the input image.

Loaded using `$readmemh`.

---

## **5.10 `feature_mem_out.v`**

Stores the final processed output after:

* convolution
* ReLU
* pooling

---

## **5.11 `controller.v`**

This is a simple “traffic controller.”

It decides:

* when a 3×3 window is ready
* when MAC should run
* when to apply pooling
* when processing is finished

Without this, modules won’t work in sync.

---

## **5.12 `cnn_top.v`**

The top module that wires everything together.

When running simulation, **simulate this module**.

---

# 🧪 6. Testbenches

### ✔ `tb_mac_3x3.v`

Tests the multiply-accumulate logic.

### ✔ `tb_line_window.v`

Tests whether the 3×3 window slides correctly.

### ✔ `tb_cnn_top.v`

Runs the complete CNN pipeline from input → output.

---

# 📊 7. Fixed-Point Format 

All computations use **fixed-point** numbers, not floating-point.

Default: **Q8.8 format**

Meaning:

* 16-bit total
* 8 bits for integer part
* 8 bits for decimal part

Example:

```
5.25  →  00000101.01000000 (binary)
```

This is how real accelerators store CNN weights and activations.

---

# 📈 8. How to Compare with Python (Golden Reference)

1. Prepare input image + weights

2. Run `scripts/golden_cnn.py`

3. This script performs:

   * convolution
   * ReLU
   * pooling
   * fixed-point scaling

4. It produces:

   ```
   golden_conv_out.hex
   golden_pooled_out.hex
   ```

5. Compare these with Verilog output.

Matching values confirm hardware correctness.

---

# 🧩 9. What This Hardware Block *Can* Do

✔ Correct 3×3 convolution
✔ ReLU activation
✔ 2×2 pooling
✔ Sliding-window hardware (line buffer + window buffer)
✔ Multiple filters
✔ Works like internal engine of CNN accelerators
✔ Fully simulation-friendly
✔ Clear, modular design

---

# ⚠️ 10. What It **Cannot** Do (Yet)

❌ It does not train a CNN
❌ Not a full deep-learning accelerator
❌ No stride or padding (can be added)
❌ Works on small images only
❌ Single CNN layer only

---

# 🔮 11. Future Extensions 

* Add more filters
* Add stride and padding
* Add BatchNorm
* Add multiple layers
* Create AXI-Stream interfaces
* Port to FPGA board
* Optimize the MAC pipeline
* Add quantization-aware operations

Each of these brings you closer to a full NPU/TPU design.

---

# 🏁 12. Final Notes

This project demonstrates the **foundation of nearly every AI accelerator chip**:

* convolution
* activation
* pooling
* parallel filters
* fixed-point arithmetic
* pipelined dataflow

