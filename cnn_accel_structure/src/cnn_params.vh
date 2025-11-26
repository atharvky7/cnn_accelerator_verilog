// cnn_params.vh
// Global parameters for the CNN accelerator

`ifndef CNN_PARAMS_VH
`define CNN_PARAMS_VH

// Fixed-point format: signed DATA_WIDTH, with FRAC_BITS fractional bits.
`define DATA_WIDTH 16
`define FRAC_BITS  8

// Image dimensions (single-channel input)
`define IMG_WIDTH   8
`define IMG_HEIGHT  8

// Number of convolution filters
`define NUM_FILTERS 4

`endif
