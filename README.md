

# CNN Accelerator in Verilog

This project implements a **small hardware engine** that performs the basic operations of a Convolutional Neural Network (CNN) using **Verilog HDL**.

A CNN mainly does three things:

1. It looks at **small 3×3 blocks** of an image
2. It multiplies those pixels with **weights** and adds them
3. It passes the result through **ReLU** and **pooling**

This project recreates that behaviour in hardware, step by step, using simple and understandable modules.

The goal of this project is **not** to build a full deep-learning chip, but to clearly show how the inner building blocks of a CNN work inside hardware.

Everything is written in a clean, modular way so that even someone new to CNNs or hardware design can understand it.

---

# 1. What This Project Does (Very Simple Explanation)

Imagine you take an image and place a **small 3×3 magnifying glass** over it.
At each position, you:

* multiply each pixel with a number (weight)
* add everything
* if the number is negative, make it 0 (ReLU)
* then, in groups of 2×2, take the maximum (max-pooling)

This project builds the hardware that does exactly this automatically.

If you run the design in simulation, it will:

✔ Read an image from a hex file
✔ Slide a 3×3 window over it
✔ Calculate convolution correctly
✔ Apply ReLU
✔ Apply 2×2 max-pooling
✔ Store final results in memory

This is the same basic operation used in every modern AI vision chip.

---

# 2. Why This Project Is Useful

* It teaches the fundamentals of CNN hardware
* It lets you see how images flow through hardware
* It demonstrates sliding-window logic (line buffers)
* It shows how MAC (multiply-accumulate) hardware works
* It is extremely good for resumes and viva
* It does NOT require any FPGA board — simulation only
* Everything is written in simple Verilog modules

---

# 3. Folder Structure (Easy Overview)

```
src/         → all Verilog design files  
tb/          → testbenches for simulation  
data/        → input image, weights, and expected output  
scripts/     → Python script for golden reference  
docs/        → notes and diagrams  
README.md    → you are reading this
```

---

# 4. Explanation of Each Verilog File (Easy Language)

## 4.1 `cnn_params.vh`

A small file that stores parameters like:

* image width
* data bit-width
* number of filters

Instead of typing numbers everywhere, we keep them here.
This makes the design easier to change.

---

## 4.2 `mac_3x3.v`

This is the **heart** of the accelerator.

It takes:

* 9 image pixels
* 9 weight values

And calculates:

```
sum = p0*w0 + p1*w1 + ... + p8*w8
```

This is exactly what convolution is.

Think of it as a **mini calculator** that handles one 3×3 block.

---

## 4.3 `relu.v`

ReLU simply means:

```
If the number is negative → make it 0  
Else → keep it
```

This file does just that in one line of logic.

---

## 4.4 `maxpool_2x2.v`

Pooling reduces the size of the image.

From every 2×2 area:

```
Take the largest value
```

Simple, but very important in CNNs.

---

## 4.5 `line_buffer.v`

When doing 3×3 convolution, you need **3 rows of pixels at a time**.

But pixels arrive **one at a time** like a stream.

A line buffer stores the previous two rows so the hardware always “remembers” enough pixels to form a 3×3 window.

Analogy:
Like keeping 2 previous sentences in memory while reading a paragraph.

---

## 4.6 `window_buffer.v`

Takes the 3 rows from the line buffer and extracts the **3×3 block**.

If the line buffer is a memory assistant,
this is the **actual 3×3 magnifying glass**.

---

## 4.7 `conv_core.v`

This connects:

* line buffer
* window buffer
* MAC
* weight memory

It basically does:

```
Take 3×3 block → MAC → output
```

Many consider this the “engine room” of the accelerator.

---

## 4.8 `feature_mem_in.v`

Stores the input image in hex format.

Loaded using:

```
$readmemh("input_image.hex")
```

---

## 4.9 `feature_mem_out.v`

Stores the **final output** after convolution → ReLU → pooling.

You can write this back into a file using:

```
$writememh(...)
```

---

## 4.10 `weight_mem.v`

Stores the filter weights (the 3×3 kernel values).

Also loaded from a hex file.

---

## 4.11 `controller.v`

A small state machine that controls the overall flow:

* when to read pixels
* when a 3×3 window is valid
* when MAC can start
* when pooling starts
* when everything is finished

Without this, the modules would not work in sync.

---

## 4.12 `cnn_top.v`

This is the main module.
It connects all other modules together.

When you run a simulation, **this is the file you run**.

---

# 5. Testbenches 

Testbenches help verify each module.

## 5.1 `tb_mac_3x3.v`

Checks if the MAC unit multiplies and adds correctly.

## 5.2 `tb_line_window.v`

Checks if the 3×3 window slides correctly across the image.

## 5.3 `tb_cnn_top.v`

Runs the **full pipeline**:

* loads the image
* loads the weights
* performs convolution
* applies ReLU
* applies pooling
* prints final output

This is the main testbench to demonstrate the project.

---

# 6. Python Golden Model 

Inside `scripts/golden_cnn.py`, we simulate the same operations using Python.

This helps us check if Verilog results are correct.

The Python script:

* reads the same image and weights
* performs convolution, ReLU, and pooling
* writes a file with expected output

You can compare this file with Verilog output.

---

# 7. How to Run the Project (Vivado Simulation)

### Step 1: Open Vivado → "Run Simulation"

### Step 2: Add all files from:

* `src/`
* `tb/`

### Step 3: Set top module to:

```
tb_cnn_top
```

### Step 4: Run simulation

You will see output values printed or stored in the output memory.

---

# 8. What This Accelerator Can Do

✔ Perform 3×3 convolution
✔ Apply ReLU activation
✔ Perform 2×2 max-pooling
✔ Process small images
✔ Use multiple filters
✔ Fully simulate a CNN layer in hardware style
✔ Easy to understand and modify

---

# 9. What It Cannot Do 

❌ Cannot train a CNN
❌ Not optimized for speed or power
❌ Not a full CNN (only one conv layer)
❌ No stride, padding (unless added manually)
❌ Works on small images only
❌ Not meant for real hardware deployment yet


---

# 10. Future Improvements


* Add padding & stride
* Add more filters
* Add BatchNorm
* Add deeper layers
* Add streaming DMA interfaces
* Implement pipelining
* Port to FPGA board

Each of these makes the project even more impressive.

---

# 11. Conclusion

This project shows how the **core building blocks of a CNN** work in hardware:

* storing pixel rows
* sliding windows
* MAC operations
* activation
* pooling
