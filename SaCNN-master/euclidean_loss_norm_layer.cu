//written by miaojingshi 201708 
#include <vector>

#include "caffe/layers/euclidean_loss_norm_layer.hpp"
#include "caffe/util/math_functions.hpp"

namespace caffe {

template <typename Dtype>
void EuclideanLossNormLayer<Dtype>::Forward_gpu(const vector<Blob<Dtype>*>& bottom,
    const vector<Blob<Dtype>*>& top) {
  int count = bottom[0]->count();
  caffe_gpu_sub(
      count,
      bottom[0]->gpu_data(),
      bottom[1]->gpu_data(),
      diff_.mutable_gpu_data());
  Dtype dot;
// LOG(INFO) << "estedmated count" << bottom[0]->cpu_data()[0];
 // LOG(INFO) << "groundtruth count" << bottom[1]->cpu_data()[0];
 caffe_gpu_set(count, Dtype(1), diffdiv_.mutable_gpu_data()); 
 caffe_gpu_axpy(count, Dtype(1), bottom[1]->gpu_data(), diffdiv_.mutable_gpu_data());
   
 caffe_gpu_div(count, diff_.gpu_data(), diffdiv_.gpu_data(), diff_.mutable_gpu_data());
 caffe_gpu_dot(count, diff_.gpu_data(), diff_.gpu_data(), &dot);
 //dot = diff_.asum_data();   
 Dtype loss = dot / bottom[0]->num() / Dtype(2);
  top[0]->mutable_cpu_data()[0] = loss;
}

template <typename Dtype>
void EuclideanLossNormLayer<Dtype>::Backward_gpu(const vector<Blob<Dtype>*>& top,
    const vector<bool>& propagate_down, const vector<Blob<Dtype>*>& bottom) {
  for (int i = 0; i < 2; ++i) {
    if (propagate_down[i]) {
      const Dtype sign = (i == 0) ? 1 : -1;
      const Dtype alpha = sign * top[0]->cpu_diff()[0] / bottom[i]->num();
      caffe_gpu_axpby(
          bottom[i]->count(),              // count
          alpha,                              // alpha
          diff_.gpu_data(),                   // a
          Dtype(0),                           // beta
          bottom[i]->mutable_gpu_diff());  // b
          caffe_gpu_div(bottom[i]->count(), bottom[i]->gpu_data(), diffdiv_.gpu_data(), bottom[i]->mutable_gpu_data());
    }
  }
}

INSTANTIATE_LAYER_GPU_FUNCS(EuclideanLossNormLayer);

}  // namespace caffe
