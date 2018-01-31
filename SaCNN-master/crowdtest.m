%%%%% Copyright (c) 2017 Tencent Youtu Lab 
% Written by Miaojing Shi 
% Please email me miao0913@gmail.com if you find bugs, or have suggestions or questions!
clear all; close all;
lib = '/your/lib';
%'LD_LIBRARY_PATH=/your/hdf5/path/hdf5-1.8.14/build/install/lib/:/data1/install/cuda-7.5/lib64/:/usr/local/lib/:/d/install/mdb-mdb/libraries/liblmdb:/d/install/leveldb-1.15.0:/usr/local/opencv-2.4.10/lib/:/d/home/darwinli/tools/cuda-7.5/lib64/:/d/home/darwinli/tools/anaconda/lib:/d/runtime/gcc-4.8.4/lib64:/d/runtime/cudnn-7.5-linux-x64-v5.0/lib64/:/data1/install/cuda-7.5/lib64/:/usr/local/lib/:/d/install/mdb-mdb/libraries/liblmdb:/d/install/leveldb-1.15.0:/usr/local/opencv-2.4.10/lib/:/d/home/darwinli/tools/cuda-7.5/lib64/:/d/home/darwinli/tools/anaconda/lib:/d/runtime/gcc-4.8.4/lib64:/d/runtime/cudnn-7.5-linux-x64-v5.0/lib64/:/d/runtime/nccl-1.2.3-1-cuda7.5/lib ';
caffe_path = '/your/caffe/path/build/tools/extract_features';
caffe_model = '/your/caffemodel/path/pretrain_iter_950000.caffemodel';
lmdb2txt = 'your/caffe/path/build/tools/lmdb2txt';
root_dir = 'your/dataset/path';
image_dir = [root_dir 'test_data/images/'];
image_list = dir([image_dir '*.jpg']); 
gt_dir = [root_dir 'test_data/ground-truth/'];
gt_list = dir([gt_dir '*.mat']);
test_dir = [root_dir 'test_data/test_img/'];
if exist(test_dir)
    rmdir(test_dir, 's')
end
if exist('estdmap.db')
   rmdir('estdmap.db', 's')
   delete('estdmap.txt')
end
mkdir(test_dir);
gpu_id = 0;
type = 'resize';
fid = fopen([test_dir 'list.txt'], 'w');
nImg = length(image_list);
gtcc = zeros(nImg,1);
for kk = 1:nImg
  test_image = imread([image_dir image_list(kk).name]);
  load([gt_dir gt_list(kk).name]);
  switch type 
      case 'resize'
          test_img = test_image;
		  imsize_ori = size(test_img);
		  %% deconvolution
          test_img = imresize(test_img, [floor(imsize_ori(1)/16)*16 floor(imsize_ori(2)/16)*16]);
          imwrite(test_img, [test_dir image_list(kk).name]);
		  %%
          fprintf(fid, '%s\n', [test_dir image_list(kk).name]);
          gtcc(kk) = image_info{1}.number;
	  % ?? delete?
      case 'divide'
          imsize = size(test_image);
          orgH= imsize(1);
          orgW = imsize(2);
          xidx = randperm(ceil(orgW/2)); %%%% random select one region in the image 
          yidx = randperm(ceil(orgH/2));
          x = xidx(1);
          y = yidx(1);
          patch = test_image(y:y+sqrt(r)*orgH, x:x+sqrt(r)*orgW, :);
          imwrite(patch, [test_dir image_list(k).name(1:end-4) '_' num2str(x) '_' num2str(y) '.jpg']);
          fprintf(fid, '%s\n', [test_dir image_list(k).name(1:end-4) '_' num2str(x) '_' num2str(y) '.jpg']);
          lcc = image_info{1}.location;
          xlcc = lcc(:,1)>=x & lcc(:,1)<=x+0.5*orgW;
          ylcc = lcc(:,2)>=y & lcc(:,2)<=y+0.5*orgH;
          xylcc = xlcc&ylcc;
          gtcc(k) = sum(xylcc);
      otherwise
          error('no such type !!!')
  end
end
fclose(fid);
system([lib caffe_path ' ' caffe_model ' deploy.prototxt estdmap estdmap.db ' num2str(nImg) ' lmdb GPU ' num2str(gpu_id)]);
system([lmdb2txt ' estdmap.db >> estdmap.txt']);
cc = dlmread('estdmap.txt');
cc = sum(cc(:,:),2);
ccgtcc = [cc gtcc abs(cc-gtcc)]
MAE = mean(abs(cc-gtcc))
MSE = mean((cc-gtcc).^2)^(0.5)
