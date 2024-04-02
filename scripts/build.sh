PROJECT_DIR=$(pwd)

rm -rf $PROJECT_DIR/build

mkdir -p $PROJECT_DIR/build

cd $PROJECT_DIR/build

CC=mpiicx FC=mpiifort \
cmake -DCMAKE_BUILD_TYPE=Release ..

make -j$(nproc)

cd ..