#Test_Data_Path=/your/test/data/path
#Test_GT_path=/your/test/gt/path

LIB=/your/lib/path
CAFFE=/your/caffe/path
TMP=/build/tools/extract_features
CAFFE=${CAFFE}${TMP}
CAFFE_MODEL=/your/caffe/model
LMDB=/your/lmdb2txt/path
DATASET_PATH=/your/dataset/path
GPU_LIST=0
TMP_1=test_data/test_img/
TMP_2=list.txt
TEST_LIST_PATH=${DATASET_PATH}${TMP_1}${TMP_2}

sed -i '5d' crowdtest.m
sed -i "5i lib\ = \ \'LD_LIBRARY_PATH=$LIB\'\;" crowdtest.m
sed -i '6d' crowdtest.m
sed -i "6i caffe_path\ =\ \'$CAFFE\';" crowdtest.m
sed -i '7d' crowdtest.m
sed -i "7i caffe_model\ =\ \'$CAFFE_MODEL\'\;" crowdtest.m
sed -i '8d' crowdtest.m
sed -i "8i lmdb2txt\ =\ \'$LMDB\'\;" crowdtest.m
sed -i '9d' crowdtest.m
sed -i "9i root_dir\ =\ \'$DATASET_PATH\'\;" crowdtest.m
sed -i '23d' crowdtest.m
sed -i "23i gpu_id\ =\ $GPU_LIST\;" crowdtest.m
sed -i '9d' deploy.prototxt
sed -i "9i \ \ \ \ source:\ \"$TEST_LIST_PATH\"" deploy.prototxt 

if [ ! -x "test_result" ]; then mkdir test_result; fi
echo crowdtest | matlab -nodisplay 2>&1 | tee ./test/log.txt

mv estdmap.txt test/
mv estdmap.db test/
