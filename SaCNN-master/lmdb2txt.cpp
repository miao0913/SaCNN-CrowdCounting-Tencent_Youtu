#include <caffe/util/db.hpp>
#include <caffe/proto/caffe.pb.h>

#include <boost/shared_ptr.hpp>
using boost::shared_ptr;
using namespace caffe;

int main(int argc, char **argv)
{
  if (argc != 2)
    return 1;

  shared_ptr<db::DB> db(db::GetDB(DataParameter::LMDB));
  db->Open(argv[1], db::READ);
  shared_ptr<db::Cursor> cursor(db->NewCursor());

  for (; cursor->valid(); cursor->Next())
  {
    Datum msg;
    msg.ParseFromString(cursor->value());
    int count = msg.channels() * msg.height() * msg.width();
    for (int i = 0; i < count; i++)
      fprintf(stdout, "%g ", msg.float_data(i));
    fprintf(stdout, "\n");
  }

}
