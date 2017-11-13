#include <string>
#include "mylmdb.h"
#include <cstdio>

#include "datum.pb.h"

using namespace std;

string dbpath;

int main(int argc, char **argv)
{
  if (argc != 2)
    return 1;

  dbpath = argv[1];

  LMDB db;

  db.open(dbpath.c_str(), false);

  int numItem = db.count();
  string key, val;
  caffe::Datum msg;
  for (int i = 0; i < numItem; i ++)
  {
   // fprintf(stdout, "%d: ", i);
    db.get(key, val);
    msg.ParseFromString(val);
    const float* data = msg.float_data().data();
    int dim = msg.float_data_size();
    for (int d = 0; d < dim; d ++)
      fprintf(stdout, "%f ", data[d]);
    fprintf(stdout, "\n");
  }
  return 0;
}
