# scripts/golden_cnn.py
#
# Python golden model for the CNN accelerator.
# - Reads input_image.hex and weights.hex (16-bit signed, Q8.8 fixed-point).
# - Performs 3x3 valid convolution for NUM_FILTERS filters.
# - Applies ReLU.
# - Performs 2x2 max pooling.
# - Writes golden_conv_out.hex and golden_pooled_out.hex.

import numpy as np

DATA_WIDTH = 16
FRAC_BITS = 8
IMG_WIDTH = 8
IMG_HEIGHT = 8
NUM_FILTERS = 4

OUT_CONV_W = IMG_WIDTH - 2
OUT_CONV_H = IMG_HEIGHT - 2
OUT_POOL_W = OUT_CONV_W // 2
OUT_POOL_H = OUT_CONV_H // 2

def read_hex_vector(path, count):
    vals = []
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            v = int(line, 16)
            # interpret as signed
            if v & (1 << (DATA_WIDTH - 1)):
                v = v - (1 << DATA_WIDTH)
            vals.append(v)
    if len(vals) < count:
        vals += [0] * (count - len(vals))
    return np.array(vals[:count], dtype=np.int32)

def write_hex_vector(path, arr):
    with open(path, "w") as f:
        for v in arr:
            v16 = v & 0xFFFF
            f.write(f"{v16:04X}\n")

def to_float(v):
    return v / float(1 << FRAC_BITS)

def from_float(x):
    return int(round(x * (1 << FRAC_BITS)))

def main():
    # Read input image (single-channel) and weights
    img_flat = read_hex_vector("data/input_image.hex", IMG_WIDTH * IMG_HEIGHT)
    img = img_flat.reshape((IMG_HEIGHT, IMG_WIDTH))

    w_flat = read_hex_vector("data/weights.hex", NUM_FILTERS * 9)
    weights = w_flat.reshape((NUM_FILTERS, 3, 3))

    # Convolution + ReLU
    conv_out = np.zeros((NUM_FILTERS, OUT_CONV_H, OUT_CONV_W), dtype=np.int32)

    for f in range(NUM_FILTERS):
        k = weights[f]
        for r in range(OUT_CONV_H):
            for c in range(OUT_CONV_W):
                window = img[r:r+3, c:c+3]
                # Multiply in fixed-point
                prod = window.astype(np.int64) * k.astype(np.int64)
                s = np.sum(prod)
                # Scale down
                s = s >> FRAC_BITS
                # Clip to 16-bit range
                if s < -(1 << (DATA_WIDTH-1)):
                    s = -(1 << (DATA_WIDTH-1))
                if s > (1 << (DATA_WIDTH-1)) - 1:
                    s = (1 << (DATA_WIDTH-1)) - 1
                # ReLU
                if s < 0:
                    s = 0
                conv_out[f, r, c] = s

    # Write conv output (optional)
    conv_flat = conv_out.reshape(-1)
    write_hex_vector("data/golden_conv_out.hex", conv_flat)

    # 2x2 max pooling
    pool_out = np.zeros((NUM_FILTERS, OUT_POOL_H, OUT_POOL_W), dtype=np.int32)
    for f in range(NUM_FILTERS):
        for r in range(OUT_POOL_H):
            for c in range(OUT_POOL_W):
                r0 = 2 * r
                c0 = 2 * c
                region = conv_out[f, r0:r0+2, c0:c0+2]
                pool_out[f, r, c] = np.max(region)

    pool_flat = pool_out.reshape(-1)
    write_hex_vector("data/golden_pooled_out.hex", pool_flat)

    print("Golden model generation complete.")
    print(f"conv_out shape:  {conv_out.shape}")
    print(f"pool_out shape:  {pool_out.shape}")

if __name__ == "__main__":
    main()
