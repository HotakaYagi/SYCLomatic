// RUN: dpct --format-range=none --use-experimental-features=bindless_images -out-root %T/texture/texture_object_bindless_image %s --cuda-include-path="%cuda-path/include" -- -x cuda --cuda-host-only -std=c++14
// RUN: FileCheck --input-file %T/texture/texture_object_bindless_image/texture_object_bindless_image.dp.cpp --match-full-lines %s
// RUN: %if build_lit %{icpx -c -fsycl -DBUILD_TEST %T/texture/texture_object_bindless_image/texture_object_bindless_image.dp.cpp -o %T/texture/texture_object_bindless_image/texture_object_bindless_image.dp.o %}

// CHECK: void kernel(sycl::ext::oneapi::experimental::sampled_image_handle tex) {
__global__ void kernel(cudaTextureObject_t tex) {
  int i;
  float j, k;
  // CHECK: sycl::ext::oneapi::experimental::read_image<sycl::short2>(tex, (float)i);
  tex1Dfetch<short2>(tex, i);
  // CHECK: sycl::ext::oneapi::experimental::read_image<sycl::short2>(tex, (float)i);
  tex1D<short2>(tex, i);
  // CHECK: i = sycl::ext::oneapi::experimental::read_image<int>(tex, (float)i);
  tex1D(&i, tex, i);
  // CHECK: sycl::ext::oneapi::experimental::read_image<sycl::short2>(tex, sycl::float2(j, k));
  tex2D<short2>(tex, j, k);
  // CHECK: i = sycl::ext::oneapi::experimental::read_image<int>(tex, sycl::float2(j, k));
  tex2D(&i, tex, j, k);
}

int main() {
  void *input;
  size_t w, h, sizeInBytes, w_offest_src, h_offest_src, w_offest_dest, h_offest_dest;
  unsigned int flag;
  cudaExtent e;
  // CHECK: dpct::experimental::image_mem_ptr pArr, pArr_src;
  cudaArray_t pArr, pArr_src;
  // TODO: need support.
  // cudaMipmappedArray_t pMipMapArr;
  // CHECK: dpct::image_channel desc;
  cudaChannelFormatDesc desc;
  // CHECK: pArr = new sycl::ext::oneapi::experimental::image_mem(sycl::ext::oneapi::experimental::image_descriptor(e, desc.get_channel_order(), desc.get_channel_type()), q_ct1);
  cudaMalloc3DArray(&pArr, &desc, e);
  // CHECK: pArr = new sycl::ext::oneapi::experimental::image_mem(sycl::ext::oneapi::experimental::image_descriptor({w, h}, desc.get_channel_order(), desc.get_channel_type()), q_ct1);
  cudaMallocArray(&pArr, &desc, w, h);
  // CHECK: desc = dpct::experimental::get_channel(pArr);
  // CHECK-NEXT: e = pArr->get_range();
  // CHECK-NEXT: flag = 0;
  cudaArrayGetInfo(&desc, &e, &flag, pArr);
  // CHECK: dpct::experimental::dpct_memcpy(pArr_src, w_offest_src, h_offest_src, pArr, w_offest_dest, h_offest_dest, w, h, q_ct1);
  cudaMemcpy2DArrayToArray(pArr, w_offest_dest, h_offest_dest, pArr_src,
                           w_offest_src, h_offest_src, w, h,
                           cudaMemcpyHostToDevice);
  // CHECK: dpct::experimental::dpct_memcpy(pArr, w_offest_src, h_offest_src, input, w, w, h, q_ct1);
  cudaMemcpy2DFromArray(input, w, pArr, w_offest_src, h_offest_src, w, h,
                        cudaMemcpyHostToDevice);
  // CHECK: dpct::experimental::async_dpct_memcpy(pArr, w_offest_src, h_offest_src, input, w, w, h, q_ct1);
  cudaMemcpy2DFromArrayAsync(input, w, pArr, w_offest_src, h_offest_src, w, h,
                             cudaMemcpyHostToDevice);
  // CHECK: dpct::experimental::dpct_memcpy(input, pArr, w_offest_dest, h_offest_dest, w, w, h, q_ct1);
  cudaMemcpy2DToArray(pArr, w_offest_dest, h_offest_dest, input, w, w, h,
                      cudaMemcpyHostToDevice);
  // CHECK: dpct::experimental::async_dpct_memcpy(input, pArr, w_offest_dest, h_offest_dest, w, w, h, q_ct1);
  cudaMemcpy2DToArrayAsync(pArr, w_offest_dest, h_offest_dest, input, w, w, h,
                           cudaMemcpyHostToDevice);
  // CHECK: dpct::experimental::dpct_memcpy(pArr_src, w_offest_src, h_offest_src, pArr, w_offest_dest, h_offest_dest, w * h, q_ct1);
  cudaMemcpyArrayToArray(pArr, w_offest_dest, h_offest_dest, pArr_src,
                         w_offest_src, h_offest_src, w * h,
                         cudaMemcpyHostToDevice);
  // CHECK: dpct::experimental::dpct_memcpy(pArr, w_offest_src, h_offest_src, input, w * h, q_ct1);
  cudaMemcpyFromArray(input, pArr, w_offest_src, h_offest_src, w * h,
                      cudaMemcpyHostToDevice);
  // CHECK: dpct::experimental::async_dpct_memcpy(pArr, w_offest_src, h_offest_src, input, w * h, q_ct1);
  cudaMemcpyFromArrayAsync(input, pArr, w_offest_src, h_offest_src, w * h,
                           cudaMemcpyHostToDevice);
  // CHECK: dpct::experimental::dpct_memcpy(input, pArr, w_offest_dest, h_offest_dest, w * h, q_ct1);
  cudaMemcpyToArray(pArr, w_offest_dest, h_offest_dest, input, w * h,
                    cudaMemcpyHostToDevice);
  // CHECK: dpct::experimental::async_dpct_memcpy(input, pArr, w_offest_dest, h_offest_dest, w * h, q_ct1);
  cudaMemcpyToArrayAsync(pArr, w_offest_dest, h_offest_dest, input, w * h,
                         cudaMemcpyHostToDevice);

  // CHECK: dpct::image_data resDesc0, resDesc1, resDesc2, resDesc3, resDesc4;
  cudaResourceDesc resDesc0, resDesc1, resDesc2, resDesc3, resDesc4;
  // CHECK: resDesc0.set_data_type(dpct::image_data_type::matrix);
  resDesc0.resType = cudaResourceTypeArray;
  // CHECK: resDesc1.set_data_ptr(pArr);
  resDesc1.res.array.array = pArr;
  // TODO: need support.
  // resDesc0.resType = cudaResourceTypeMipmappedArray;
  // resDesc2.res.mipmap.mipmap = pMipMapArr;
  // CHECK: resDesc0.set_data_type(dpct::image_data_type::linear);
  resDesc0.resType = cudaResourceTypeLinear;
  // CHECK: resDesc3.set_data_ptr(input);
  resDesc3.res.linear.devPtr = input;
  // CHECK: resDesc3.set_channel(desc);
  resDesc3.res.linear.desc = desc;
  // CHECK: resDesc3.set_x(sizeInBytes);
  resDesc3.res.linear.sizeInBytes = sizeInBytes;
  // CHECK: resDesc0.set_data_type(dpct::image_data_type::pitch);
  resDesc0.resType = cudaResourceTypePitch2D;
  // CHECK: resDesc4.set_data_ptr(input);
  resDesc4.res.pitch2D.devPtr = input;
  // CHECK: resDesc4.set_channel(desc);
  resDesc4.res.pitch2D.desc = desc;
  // CHECK: resDesc4.set_x(w);
  resDesc4.res.pitch2D.width = w;
  // CHECK: resDesc4.set_y(h);
  resDesc4.res.pitch2D.height = h;
  // CHECK: resDesc4.set_pitch(sizeInBytes);
  resDesc4.res.pitch2D.pitchInBytes = sizeInBytes;
  {
    // CHECK: dpct::image_data resDesc;
    cudaResourceDesc resDesc;
    // CHECK: resDesc.set_data(pArr);
    resDesc.resType = cudaResourceTypeArray;
    resDesc.res.array.array = pArr;
  }
  {
    // CHECK: dpct::image_data resDesc;
    cudaResourceDesc resDesc;
    // CHECK: resDesc.set_data(input, sizeInBytes, desc);
    resDesc.resType = cudaResourceTypeLinear;
    resDesc.res.linear.devPtr = input;
    resDesc.res.linear.desc = desc;
    resDesc.res.linear.sizeInBytes = sizeInBytes;
  }
  {
    // CHECK: dpct::image_data resDesc;
    cudaResourceDesc resDesc;
    // CHECK: resDesc.set_data(input, w, h, sizeInBytes, desc);
    resDesc.resType = cudaResourceTypePitch2D;
    resDesc.res.pitch2D.devPtr = input;
    resDesc.res.pitch2D.desc = desc;
    resDesc.res.pitch2D.width = w;
    resDesc.res.pitch2D.height = h;
    resDesc.res.pitch2D.pitchInBytes = sizeInBytes;
  }

  // CHECK: dpct::sampling_info texDesc1, texDesc2, texDesc3, texDesc4;
  cudaTextureDesc texDesc1, texDesc2, texDesc3, texDesc4;
  // CHECK: texDesc1.set(sycl::addressing_mode::repeat);
  texDesc1.addressMode[0] = cudaAddressModeWrap;
  // CHECK: texDesc2.set(sycl::addressing_mode::clamp_to_edge);
  texDesc2.addressMode[0] = cudaAddressModeClamp;
  // CHECK: texDesc3.set(sycl::addressing_mode::mirrored_repeat);
  texDesc3.addressMode[0] = cudaAddressModeMirror;
  // CHECK: texDesc4.set(sycl::addressing_mode::clamp);
  texDesc4.addressMode[0] = cudaAddressModeBorder;
  // CHECK: texDesc1.set(sycl::filtering_mode::nearest);
  texDesc1.filterMode = cudaFilterModePoint;
  // CHECK: texDesc2.set(sycl::filtering_mode::linear);
  texDesc2.filterMode = cudaFilterModeLinear;
  // CHECK: texDesc3.set(sycl::coordinate_normalization_mode::unnormalized);
  texDesc3.normalizedCoords = 0;
  // CHECK: texDesc4.set(sycl::coordinate_normalization_mode::normalized);
  texDesc4.normalizedCoords = 1;

  // CHECK: sycl::ext::oneapi::experimental::sampled_image_handle tex;
  cudaTextureObject_t tex;
  // CHECK: tex = dpct::experimental::create_bindless_image(resDesc1, texDesc1);
  cudaCreateTextureObject(&tex, &resDesc1, &texDesc1, NULL);
  // CHECK: desc = dpct::experimental::get_channel(pArr);
  cudaGetChannelDesc(&desc, pArr);
  // CHECK: resDesc1 = dpct::experimental::get_data(tex);
  cudaGetTextureObjectResourceDesc(&resDesc1, tex);
  // CHECK: texDesc1 = dpct::experimental::get_sampling_info(tex);
  cudaGetTextureObjectTextureDesc(&texDesc1, tex);
  // CHECK: q_ct1.parallel_for(
  // CHECK-NEXT: sycl::nd_range<3>(sycl::range<3>(1, 1, 1), sycl::range<3>(1, 1, 1)),
  // CHECK-NEXT: [=](sycl::nd_item<3> item_ct1) {
  // CHECK-NEXT:   kernel(tex);
  // CHECK-NEXT: });
  kernel<<<1, 1>>>(tex);
  // CHECK: dpct::experimental::destroy_bindless_image(tex, q_ct1);
  cudaDestroyTextureObject(tex);
  // CHECK: sycl::ext::oneapi::experimental::free_image_mem(pArr->get_handle(), sycl::ext::oneapi::experimental::image_type::standard, dpct::get_in_order_queue());
  cudaFreeArray(pArr);
  return 0;
}
