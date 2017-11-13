PROTOC=/usr/local/bin/protoc
INC=-I/usr/local/include
LIB_PATH=-L/usr/local/lib
LIBS=-llmdb -lprotobuf

all: lmdb2txt.cpp datum.pb.cc lmdb2txt_data.cpp
	g++ lmdb2txt.cpp datum.pb.cc $(INC) $(LIB_PATH) $(LIBS) -o lmdb2txt
	g++ lmdb2txt_data.cpp datum.pb.cc $(INC) $(LIB_PATH) $(LIBS) -o lmdb2txt_data

datum.pb.cc: datum.proto
	$(PROTOC) datum.proto --cpp_out=.

clean: 
	rm -rf lmdb2txt
	rm -rf *pb.*

