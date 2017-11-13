Train_Data_Path=/your/train/data/path
Train_GT_Path=/your/train/gt/path

CAFFE=/your/caffe/path
TMP=/build/tools/caffe
CAFFE=${CAFFE}${TMP}
SOLVER=./solver.prototxt
GPU_LIST=0
LOG=log.txt
## iter ? change ?
WEIGHT=/model/Part_B/pretrain_iter_950000.caffemodel

echo "Please input train average loss: "
read average_loss

sed -i '13d' train.prototxt train_c.prototxt
sed -i "13i \	source:\ \"$Train_Data_Path\"" train.prototxt train_c.prototxt
sed -i '29d' train.prototxt train_c.prototxt
sed -i "29i \	source:\ \"$Train_GT_Path\"" train.prototxt train_c.prototxt

sed -i '4d' solver.prototxt
sed -i "4i average_loss:\ $average_loss" solver.prototxt

if [ ! -x "result" ]; then mkdir result; fi

if [ -f $LOG ]; then rm $LOG; fi
$CAFFE train --solver=$SOLVER --gpu=$GPU_LIST 2>&1 | tee $LOG

mv log.txt result/
cp solver.prototxt solver_old.prototxt

#=== count loss ===#
sed -i '3d' solver.prototxt
sed -i "3i base_lr:\ 1e-8" solver.prototxt
sed -i '4d' solver.prototxt
sed -i "4i average_loss:\ $average_loss" solver.prototxt
sed -i '5d' solver.prototxt
sed -i "5i lr_policy:\ \"step\"" solver.prototxt
sed -i '7d' solver.prototxt
sed -i '7d' solver.prototxt
sed -i "7i stepsize:\ 500000" solver.prototxt
sed -i '8d' solver.prototxt
sed -i "8i max_iter:\ 300000" solver.prototxt
sed -i '11d' solver.prototxt
sed -i "11i snapshot:\ 4000" solver.prototxt
sed -i '12d' solver.prototxt
sed -i "12i snapshot_prefix:\ \"./result_c/pretrain\"" solver.prototxt

if [ ! -x "result_c"]; then mkdir result_c; fi

if [ -f $LOG ]; then rm $LOG; fi
$CAFFE train --solver=$SNAPSHOT --gpu=$GPU_LIST --weights=$WEIGHT 2>&1 | tee $LOG
mv log.txt result_c/