// Option: --use-dpcpp-extensions=intel_device_math
#include "cuda_bf16.h"

__global__ void test(__nv_bfloat16 b) {
  // Start
  __bfloat16_as_short(b /*__nv_bfloat16*/);
  // End
}
