## Crowd Counting Via Scale-adaptive Convolutional Neural Network
By ZHANG Lu, SHI Miaojing and CHEN Qiaobo   
This implementation is written by ZHANG Lu and SHI Miaojing.

### Introduction 
This project is an implementation of the crowd counting method proposed in our arxiv paper - [Crowd counting via scale-adaptive convolutional neural network (SaCNN)](http://arxiv.org/abs/1711.04433). SaCNN extracts feature maps from multiple layers and adapts them to produce the final density map. A relative count loss is proposed to improve the network generalization on crowd scenes with few pedestrians; a new dataset SmartCity is collected for this scenario. 

### License
This code is released under the MIT License (Please refer to the LICENSE file for details). It can only be used for academic research purposes. Tencent has all the rights reserved (Contact: Chengjie Wang jasoncjwang@tencent.com).

### Citation
Please cite our paper in your publications if it helps your research:
```
@article{zhang17sacnn,
Author = {Lu Zhang*, Miaojing Shi* and Qiaobo Chen},
Title = {Crowd Counting Via Sacle-adaptive Convolutional Neural Network},
booktitle= = {IEEE Winter Conference on Applications of Computer Vision (WACV)},
Year = {2018}
}
```

### Dependencies and Installation 
We have tested the implementation on Linux with GPU Nvidia Tesla M40. CUDA7.5 and CuDNN v5 is tested. The other version should be working. lmdb2txt (included) has to be compiled with cmake beforehand. Caffe installation is pre-required. The euclidean\_loss\_norm\_layers inside the repository are for the count loss implemtantion in this paper; they should be added into caffe and recompiled.      

### Training and Test
1. Clone the SaCNN repository 
```
$ git clone https://github.com/miao0913/SaCNN-CrowdCounting-Tencent_Youtu.git
```

2. Train SaCNN: 
```
$ sh train_sacnn.sh
```

3. Test SaCNN: 
```
$ sh test_sacnn.sh  
$ MATLAB crowdtest 
```
Pretrained model on ShanghaiTech PartA and PartB can be downloaded from [BaiduYun](https://pan.baidu.com/s/1hsEMDVI) or [GoogleDrive](https://drive.google.com/drive/folders/1rSALdD_iG30TXR5m8edvQ4bvID2yUti8?usp=sharing). 


### SmartCity Dataset
We have collected a new dataset SmartCity in the paper. It consists of 50 images in total collected from ten city scenes including office entrance, sidewalk, atrium, shopping mall etc.. Some examples are shown in Fig. 4 in our arxiv paper. Unlike the existing crowd counting datasets with images of hundreds/thousands of pedestrians and nearly all the images being taken outdoors, SmartCity has few pedestrians in images and consists of both outdoor and indoor scenes: the average number of pedestrians is only 7.4 with minimum being 1 and maximum being 14. We use this set to test the generalization ability of the proposed framework on very sparse crowd scenes.

1. The dataset is available. This paper is done in Tencent Youtu Lab. Tecent has the copyright of the dataset. So please email Lu Zhang/Miaojing Shi with your name and affiliation to get the download link. It's better to use your official email address.
2. These data can only be used for academic research purposes.

### Q&A
Please send message to Lu Zhang (zhanlgu330@gmail.com)/Miaojing Shi (miao0913@gmail.com) if you have any questions.

