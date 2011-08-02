#ifndef MYSQL2_EXT
#define MYSQL2_EXT

#include <ruby.h>
#include <fcntl.h>

#ifdef HAVE_MYSQL_H
#include <mysql.h>
#include <mysql_com.h>
#include <errmsg.h>
#include <mysqld_error.h>
#else
#include <mysql/mysql.h>
#include <mysql/mysql_com.h>
#include <mysql/errmsg.h>
#include <mysql/mysqld_error.h>
#endif

#ifdef HAVE_RUBY_ENCODING_H
#include <ruby/encoding.h>
#endif

#if defined(__GNUC__) && (__GNUC__ >= 3)
#define RB_MYSQL_UNUSED __attribute__ ((unused))
#else
#define RB_MYSQL_UNUSED
#endif

#include <client.h>
#include <result.h>

#endif
