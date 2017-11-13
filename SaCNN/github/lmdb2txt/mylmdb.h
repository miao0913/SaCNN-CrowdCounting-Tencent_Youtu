#ifndef MYLMDB_H
#define MYLMDB_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/stat.h> // mkdir


#include <string>
#include <vector>

#include <lmdb.h>

class LMDB
{
public:
    LMDB()
    {
        mdb_env = 0;
        mdb_cursor_ = 0;
    }

    ~LMDB()
    {
        close();
    }

    int open(const char* path, bool write)
    {
        int ret;

        //if (write)
        //{
        //    ret = mkdir(path, 0744);
        //    if (ret != 0)
        //    {
        //        fprintf(stderr, "mkdir failed %d\n", ret);
        //        return -1;
        //    }
        //}

        ret = mdb_env_create(&mdb_env);
        if (ret != 0)
        {
            fprintf(stderr, "mdb_env_create failed %d\n", ret);
            return -1;
        }

        ret = mdb_env_set_mapsize(mdb_env, 1024 * 1024 * 1024);// 1024M
        if (ret != 0)
        {
            fprintf(stderr, "mdb_env_set_mapsize failed %d\n", ret);
            return -1;
        }

        unsigned int flags = 0;
        if (!write)
        {
            flags = MDB_RDONLY | MDB_NOTLS;
        }

        ret = mdb_env_open(mdb_env, path, flags, 0664);
        if (ret != 0)
        {
            fprintf(stderr, "mdb_env_open failed %d\n", ret);
            return -1;
        }

        if (!write)
        {
            // open cursor
            mdb_txn_begin(mdb_env, NULL, MDB_RDONLY, &mdb_txn_);
            mdb_dbi_open(mdb_txn_, NULL, 0, &mdb_dbi_);

            mdb_cursor_open(mdb_txn_, mdb_dbi_, &mdb_cursor_);

            mdb_cursor_get(mdb_cursor_, &mdb_key_, &mdb_value_, MDB_FIRST);
        }

        return 0;
    }

    void close()
    {
        if (mdb_env)
        {
            if (mdb_cursor_)
            {
                // close cursor
                mdb_cursor_close(mdb_cursor_);
                mdb_txn_abort(mdb_txn_);
                mdb_dbi_close(mdb_env, mdb_dbi_);
            }

            mdb_env_close(mdb_env);
            mdb_env = 0;
        }
    }

    void commit()
    {
        if (keys.empty())
            return;

        MDB_txn* mdb_txn;
        MDB_dbi mdb_dbi;

        int ret;

        ret = mdb_txn_begin(mdb_env, NULL, 0, &mdb_txn);
        if (ret != 0)
        {
            fprintf(stderr, "mdb_txn_begin failed %d\n", ret);
            return;
        }
        ret = mdb_dbi_open(mdb_txn, NULL, 0, &mdb_dbi);
        if (ret != 0)
        {
            fprintf(stderr, "mdb_dbi_open failed %d\n", ret);
            return;
        }

        MDB_val mdb_key;
        MDB_val mdb_data;

        for (int i = 0; i < keys.size(); i++)
        {
            mdb_key.mv_size = keys[i].size();
            mdb_key.mv_data = const_cast<char*>(keys[i].data());
            mdb_data.mv_size = values[i].size();
            mdb_data.mv_data = const_cast<char*>(values[i].data());

            ret = mdb_put(mdb_txn, mdb_dbi, &mdb_key, &mdb_data, MDB_APPEND);
            if (ret == MDB_MAP_FULL)
            {
                // double the map size and retry
                mdb_txn_abort(mdb_txn);
                mdb_dbi_close(mdb_env, mdb_dbi);
                DoubleMapSize();
                commit();
                return;
            }
            if (ret != 0)
            {
                fprintf(stderr, "mdb_put failed %d\n", ret);
                return;
            }
        }

        // commit the transaction
        ret = mdb_txn_commit(mdb_txn);
        if (ret == MDB_MAP_FULL)
        {
            // double the map size and retry
            mdb_dbi_close(mdb_env, mdb_dbi);
            DoubleMapSize();
            commit();
            return;
        }
        if (ret != 0)
        {
            fprintf(stderr, "mdb_txn_commit failed %d\n", ret);
            return;
        }

        // cleanup
        mdb_dbi_close(mdb_env, mdb_dbi);
        keys.clear();
        values.clear();
    }

    void put(const std::string& key_str, const std::string& value_str)
    {
        keys.push_back(key_str);
        values.push_back(value_str);
    }

    size_t count()
    {
        struct MDB_stat current_stat;
        mdb_env_stat(mdb_env, &current_stat);
        return current_stat.ms_entries;
    }

    void get(std::string& key_str, std::string& value_str)
    {
        key_str = std::string(static_cast<const char*>(mdb_key_.mv_data), mdb_key_.mv_size);
        value_str = std::string(static_cast<const char*>(mdb_value_.mv_data), mdb_value_.mv_size);

        mdb_cursor_get(mdb_cursor_, &mdb_key_, &mdb_value_, MDB_NEXT);
    }

protected:
    void DoubleMapSize()
    {
        struct MDB_envinfo current_info;
        mdb_env_info(mdb_env, &current_info);
        size_t new_size = current_info.me_mapsize * 2;

        fprintf(stderr, "new_size %lld\n", new_size);

        mdb_env_set_mapsize(mdb_env, new_size);
    }

private:
    MDB_env* mdb_env;

    // write buffer
    std::vector<std::string> keys;
    std::vector<std::string> values;

    // read cursor
    MDB_txn* mdb_txn_;
    MDB_dbi mdb_dbi_;
    MDB_cursor* mdb_cursor_;
    MDB_val mdb_key_, mdb_value_;
};

#endif // MYLMDB_H
