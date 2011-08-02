#include <mysql2_ext.h>
#include <client.h>
#include <errno.h>

VALUE cMysql2Client;
extern VALUE mMysql2, cMysql2Error;
static VALUE intern_encoding_from_charset;
static ID sym_id, sym_version, sym_async, sym_symbolize_keys, sym_as, sym_array;
static ID intern_merge, intern_error_number_eql, intern_sql_state_eql;

#define REQUIRE_OPEN_DB(wrapper) \
  if(wrapper->closed) { \
    rb_raise(cMysql2Error, "closed MySQL connection"); \
    return Qnil; \
  }

#define MARK_CONN_INACTIVE(conn) \
  wrapper->active = 0

#define GET_CLIENT(self) \
  mysql_client_wrapper *wrapper; \
  Data_Get_Struct(self, mysql_client_wrapper, wrapper)

/*
 * used to pass all arguments to mysql_real_connect while inside
 * rb_thread_blocking_region
 */
struct nogvl_connect_args {
  MYSQL *mysql;
  const char *host;
  const char *user;
  const char *passwd;
  const char *db;
  unsigned int port;
  const char *unix_socket;
  unsigned long client_flag;
};

/*
 * used to pass all arguments to mysql_send_query while inside
 * rb_thread_blocking_region
 */
struct nogvl_send_query_args {
  MYSQL *mysql;
  VALUE sql;
};

/*
 * non-blocking mysql_*() functions that we won't be wrapping since
 * they do not appear to hit the network nor issue any interruptible
 * or blocking system calls.
 *
 * - mysql_affected_rows()
 * - mysql_error()
 * - mysql_fetch_fields()
 * - mysql_fetch_lengths() - calls cli_fetch_lengths or emb_fetch_lengths
 * - mysql_field_count()
 * - mysql_get_client_info()
 * - mysql_get_client_version()
 * - mysql_get_server_info()
 * - mysql_get_server_version()
 * - mysql_insert_id()
 * - mysql_num_fields()
 * - mysql_num_rows()
 * - mysql_options()
 * - mysql_real_escape_string()
 * - mysql_ssl_set()
 */

static void rb_mysql_client_mark(void * wrapper) {
  mysql_client_wrapper * w = wrapper;
  if (w) {
    rb_gc_mark(w->encoding);
  }
}

static VALUE rb_raise_mysql2_error(MYSQL *client) {
  VALUE e = rb_exc_new2(cMysql2Error, mysql_error(client));
  rb_funcall(e, intern_error_number_eql, 1, INT2NUM(mysql_errno(client)));
  rb_funcall(e, intern_sql_state_eql, 1, rb_tainted_str_new2(mysql_sqlstate(client)));
  rb_exc_raise(e);
  return Qnil;
}

static VALUE nogvl_init(void *ptr) {
  MYSQL *client;

  /* may initialize embedded server and read /etc/services off disk */
  client = mysql_init((MYSQL *)ptr);
  return client ? Qtrue : Qfalse;
}

static VALUE nogvl_connect(void *ptr) {
  struct nogvl_connect_args *args = ptr;
  MYSQL *client;

  do {
    client = mysql_real_connect(args->mysql, args->host,
                                args->user, args->passwd,
                                args->db, args->port, args->unix_socket,
                                args->client_flag);
  } while (! client && errno == EINTR && (errno = 0) == 0);

  return client ? Qtrue : Qfalse;
}

static VALUE nogvl_close(void *ptr) {
  mysql_client_wrapper *wrapper = ptr;
  if (!wrapper->closed) {
    wrapper->closed = 1;

    /*
     * we'll send a QUIT message to the server, but that message is more of a
     * formality than a hard requirement since the socket is getting shutdown
     * anyways, so ensure the socket write does not block our interpreter
     *
     *
     * if the socket is dead we have no chance of blocking,
     * so ignore any potential fcntl errors since they don't matter
     */
#ifndef _WIN32
    int flags = fcntl(wrapper->client->net.fd, F_GETFL);
    if (flags > 0 && !(flags & O_NONBLOCK))
      fcntl(wrapper->client->net.fd, F_SETFL, flags | O_NONBLOCK);
#else
    u_long iMode = 1;
    ioctlsocket(wrapper->client->net.fd, FIONBIO, &iMode);
#endif

    mysql_close(wrapper->client);
    free(wrapper->client);
  }

  return Qnil;
}

static void rb_mysql_client_free(void * ptr) {
  mysql_client_wrapper *wrapper = (mysql_client_wrapper *)ptr;

  nogvl_close(wrapper);

  xfree(ptr);
}

static VALUE allocate(VALUE klass) {
  VALUE obj;
  mysql_client_wrapper * wrapper;
  obj = Data_Make_Struct(klass, mysql_client_wrapper, rb_mysql_client_mark, rb_mysql_client_free, wrapper);
  wrapper->encoding = Qnil;
  wrapper->active = 0;
  wrapper->closed = 1;
  wrapper->client = (MYSQL*)malloc(sizeof(MYSQL));
  return obj;
}

static VALUE rb_connect(VALUE self, VALUE user, VALUE pass, VALUE host, VALUE port, VALUE database, VALUE socket, VALUE flags) {
  struct nogvl_connect_args args;
  GET_CLIENT(self);

  args.host = NIL_P(host) ? "localhost" : StringValuePtr(host);
  args.unix_socket = NIL_P(socket) ? NULL : StringValuePtr(socket);
  args.port = NIL_P(port) ? 3306 : NUM2INT(port);
  args.user = NIL_P(user) ? NULL : StringValuePtr(user);
  args.passwd = NIL_P(pass) ? NULL : StringValuePtr(pass);
  args.db = NIL_P(database) ? NULL : StringValuePtr(database);
  args.mysql = wrapper->client;
  args.client_flag = NUM2ULONG(flags);

  if (rb_thread_blocking_region(nogvl_connect, &args, RUBY_UBF_IO, 0) == Qfalse) {
    // unable to connect
    return rb_raise_mysql2_error(wrapper->client);
  }

  return self;
}

/*
 * Immediately disconnect from the server, normally the garbage collector
 * will disconnect automatically when a connection is no longer needed.
 * Explicitly closing this will free up server resources sooner than waiting
 * for the garbage collector.
 */
static VALUE rb_mysql_client_close(VALUE self) {
  GET_CLIENT(self);

  if (!wrapper->closed) {
    rb_thread_blocking_region(nogvl_close, wrapper, RUBY_UBF_IO, 0);
  }

  return Qnil;
}

/*
 * mysql_send_query is unlikely to block since most queries are small
 * enough to fit in a socket buffer, but sometimes large UPDATE and
 * INSERTs will cause the process to block
 */
static VALUE nogvl_send_query(void *ptr) {
  struct nogvl_send_query_args *args = ptr;
  int rv;
  const char *sql = StringValuePtr(args->sql);
  long sql_len = RSTRING_LEN(args->sql);

  rv = mysql_send_query(args->mysql, sql, sql_len);

  return rv == 0 ? Qtrue : Qfalse;
}

/*
 * even though we did rb_thread_select before calling this, a large
 * response can overflow the socket buffers and cause us to eventually
 * block while calling mysql_read_query_result
 */
static VALUE nogvl_read_query_result(void *ptr) {
  MYSQL * client = ptr;
  my_bool res = mysql_read_query_result(client);

  return res == 0 ? Qtrue : Qfalse;
}

/* mysql_store_result may (unlikely) read rows off the socket */
static VALUE nogvl_store_result(void *ptr) {
  MYSQL * client = ptr;
  return (VALUE)mysql_store_result(client);
}

static VALUE rb_mysql_client_async_result(VALUE self) {
  MYSQL_RES * result;
  GET_CLIENT(self);

  REQUIRE_OPEN_DB(wrapper);
  if (rb_thread_blocking_region(nogvl_read_query_result, wrapper->client, RUBY_UBF_IO, 0) == Qfalse) {
    // an error occurred, mark this connection inactive
    MARK_CONN_INACTIVE(self);
    return rb_raise_mysql2_error(wrapper->client);
  }

  result = (MYSQL_RES *)rb_thread_blocking_region(nogvl_store_result, wrapper->client, RUBY_UBF_IO, 0);

  // we have our result, mark this connection inactive
  MARK_CONN_INACTIVE(self);

  if (result == NULL) {
    if (mysql_field_count(wrapper->client) != 0) {
      rb_raise_mysql2_error(wrapper->client);
    }
    return Qnil;
  }

  VALUE resultObj = rb_mysql_result_to_obj(result);
  // pass-through query options for result construction later
  rb_iv_set(resultObj, "@query_options", rb_funcall(rb_iv_get(self, "@query_options"), rb_intern("dup"), 0));

#ifdef HAVE_RUBY_ENCODING_H
  mysql2_result_wrapper * result_wrapper;
  GetMysql2Result(resultObj, result_wrapper);
  result_wrapper->encoding = wrapper->encoding;
#endif
  return resultObj;
}

static VALUE rb_mysql_client_query(int argc, VALUE * argv, VALUE self) {
  struct nogvl_send_query_args args;
  fd_set fdset;
  int fd, retval;
  int async = 0;
  VALUE opts, defaults;
  GET_CLIENT(self);

  REQUIRE_OPEN_DB(wrapper);
  args.mysql = wrapper->client;

  // see if this connection is still waiting on a result from a previous query
  if (wrapper->active == 0) {
    // mark this connection active
    wrapper->active = 1;
  } else {
    rb_raise(cMysql2Error, "This connection is still waiting for a result, try again once you have the result");
  }

  defaults = rb_iv_get(self, "@query_options");
  if (rb_scan_args(argc, argv, "11", &args.sql, &opts) == 2) {
    opts = rb_funcall(defaults, intern_merge, 1, opts);
    rb_iv_set(self, "@query_options", opts);

    if (rb_hash_aref(opts, sym_async) == Qtrue) {
      async = 1;
    }
  } else {
    opts = defaults;
  }

#ifdef HAVE_RUBY_ENCODING_H
  rb_encoding *conn_enc = rb_to_encoding(wrapper->encoding);
  // ensure the string is in the encoding the connection is expecting
  args.sql = rb_str_export_to_enc(args.sql, conn_enc);
#endif

  if (rb_thread_blocking_region(nogvl_send_query, &args, RUBY_UBF_IO, 0) == Qfalse) {
    // an error occurred, we're not active anymore
    MARK_CONN_INACTIVE(self);
    return rb_raise_mysql2_error(wrapper->client);
  }

  if (!async) {
    // the below code is largely from do_mysql
    // http://github.com/datamapper/do
    fd = wrapper->client->net.fd;
    for(;;) {
      FD_ZERO(&fdset);
      FD_SET(fd, &fdset);

      retval = rb_thread_select(fd + 1, &fdset, NULL, NULL, NULL);

      if (retval < 0) {
        rb_sys_fail(0);
      }

      if (retval > 0) {
        break;
      }
    }

    VALUE result = rb_mysql_client_async_result(self);

    return result;
  } else {
    return Qnil;
  }
}

static VALUE rb_mysql_client_escape(VALUE self, VALUE str) {
  VALUE newStr;
  unsigned long newLen, oldLen;
  GET_CLIENT(self);

  REQUIRE_OPEN_DB(wrapper);
  Check_Type(str, T_STRING);
#ifdef HAVE_RUBY_ENCODING_H
  rb_encoding *default_internal_enc = rb_default_internal_encoding();
  rb_encoding *conn_enc = rb_to_encoding(wrapper->encoding);
  // ensure the string is in the encoding the connection is expecting
  str = rb_str_export_to_enc(str, conn_enc);
#endif

  oldLen = RSTRING_LEN(str);
  newStr = rb_str_new(0, oldLen*2+1);

  newLen = mysql_real_escape_string(wrapper->client, RSTRING_PTR(newStr), StringValuePtr(str), oldLen);
  if (newLen == oldLen) {
    // no need to return a new ruby string if nothing changed
    return str;
  } else {
    rb_str_resize(newStr, newLen);
#ifdef HAVE_RUBY_ENCODING_H
    rb_enc_associate(newStr, conn_enc);
    if (default_internal_enc) {
      newStr = rb_str_export_to_enc(newStr, default_internal_enc);
    }
#endif
    return newStr;
  }
}

static VALUE rb_mysql_client_info(VALUE self) {
  VALUE version = rb_hash_new(), client_info;
  GET_CLIENT(self);

#ifdef HAVE_RUBY_ENCODING_H
  rb_encoding *default_internal_enc = rb_default_internal_encoding();
  rb_encoding *conn_enc = rb_to_encoding(wrapper->encoding);
#endif

  rb_hash_aset(version, sym_id, LONG2NUM(mysql_get_client_version()));
  client_info = rb_str_new2(mysql_get_client_info());
#ifdef HAVE_RUBY_ENCODING_H
  rb_enc_associate(client_info, conn_enc);
  if (default_internal_enc) {
    client_info = rb_str_export_to_enc(client_info, default_internal_enc);
  }
#endif
  rb_hash_aset(version, sym_version, client_info);
  return version;
}

static VALUE rb_mysql_client_server_info(VALUE self) {
  VALUE version, server_info;
  GET_CLIENT(self);

  REQUIRE_OPEN_DB(wrapper);
#ifdef HAVE_RUBY_ENCODING_H
  rb_encoding *default_internal_enc = rb_default_internal_encoding();
  rb_encoding *conn_enc = rb_to_encoding(wrapper->encoding);
#endif

  version = rb_hash_new();
  rb_hash_aset(version, sym_id, LONG2FIX(mysql_get_server_version(wrapper->client)));
  server_info = rb_str_new2(mysql_get_server_info(wrapper->client));
#ifdef HAVE_RUBY_ENCODING_H
  rb_enc_associate(server_info, conn_enc);
  if (default_internal_enc) {
    server_info = rb_str_export_to_enc(server_info, default_internal_enc);
  }
#endif
  rb_hash_aset(version, sym_version, server_info);
  return version;
}

static VALUE rb_mysql_client_socket(VALUE self) {
  GET_CLIENT(self);
  REQUIRE_OPEN_DB(wrapper);
  return INT2NUM(wrapper->client->net.fd);
}

static VALUE rb_mysql_client_last_id(VALUE self) {
  GET_CLIENT(self);
  REQUIRE_OPEN_DB(wrapper);
  return ULL2NUM(mysql_insert_id(wrapper->client));
}

static VALUE rb_mysql_client_affected_rows(VALUE self) {
  GET_CLIENT(self);
  my_ulonglong retVal;

  REQUIRE_OPEN_DB(wrapper);
  retVal = mysql_affected_rows(wrapper->client);
  if (retVal == (my_ulonglong)-1) {
    rb_raise_mysql2_error(wrapper->client);
  }
  return ULL2NUM(retVal);
}

static VALUE set_reconnect(VALUE self, VALUE value) {
  my_bool reconnect;
  GET_CLIENT(self);

  if(!NIL_P(value)) {
    reconnect = value == Qfalse ? 0 : 1;

    /* set default reconnect behavior */
    if (mysql_options(wrapper->client, MYSQL_OPT_RECONNECT, &reconnect)) {
      /* TODO: warning - unable to set reconnect behavior */
      rb_warn("%s\n", mysql_error(wrapper->client));
    }
  }
  return value;
}

static VALUE set_connect_timeout(VALUE self, VALUE value) {
  unsigned int connect_timeout = 0;
  GET_CLIENT(self);

  if(!NIL_P(value)) {
    connect_timeout = NUM2INT(value);
    if(0 == connect_timeout) return value;

    /* set default connection timeout behavior */
    if (mysql_options(wrapper->client, MYSQL_OPT_CONNECT_TIMEOUT, &connect_timeout)) {
      /* TODO: warning - unable to set connection timeout */
      rb_warn("%s\n", mysql_error(wrapper->client));
    }
  }
  return value;
}

static VALUE set_charset_name(VALUE self, VALUE value) {
  char * charset_name;
  GET_CLIENT(self);

#ifdef HAVE_RUBY_ENCODING_H
  VALUE new_encoding;
  new_encoding = rb_funcall(cMysql2Client, intern_encoding_from_charset, 1, value);
  if (new_encoding == Qnil) {
    rb_raise(cMysql2Error, "Unsupported charset: '%s'", RSTRING_PTR(value));
  } else {
    if (wrapper->encoding == Qnil) {
      wrapper->encoding = new_encoding;
    }
  }
#endif

  charset_name = StringValuePtr(value);

  if (mysql_options(wrapper->client, MYSQL_SET_CHARSET_NAME, charset_name)) {
    /* TODO: warning - unable to set charset */
    rb_warn("%s\n", mysql_error(wrapper->client));
  }

  return value;
}

static VALUE set_ssl_options(VALUE self, VALUE key, VALUE cert, VALUE ca, VALUE capath, VALUE cipher) {
  GET_CLIENT(self);

  if(!NIL_P(ca) || !NIL_P(key)) {
    mysql_ssl_set(wrapper->client,
        NIL_P(key) ? NULL : StringValuePtr(key),
        NIL_P(cert) ? NULL : StringValuePtr(cert),
        NIL_P(ca) ? NULL : StringValuePtr(ca),
        NIL_P(capath) ? NULL : StringValuePtr(capath),
        NIL_P(cipher) ? NULL : StringValuePtr(cipher));
  }

  return self;
}

static VALUE init_connection(VALUE self) {
  GET_CLIENT(self);

  if (rb_thread_blocking_region(nogvl_init, wrapper->client, RUBY_UBF_IO, 0) == Qfalse) {
    /* TODO: warning - not enough memory? */
    return rb_raise_mysql2_error(wrapper->client);
  }

  wrapper->closed = 0;
  return self;
}

void init_mysql2_client() {
  cMysql2Client = rb_define_class_under(mMysql2, "Client", rb_cObject);

  rb_define_alloc_func(cMysql2Client, allocate);

  rb_define_method(cMysql2Client, "close", rb_mysql_client_close, 0);
  rb_define_method(cMysql2Client, "query", rb_mysql_client_query, -1);
  rb_define_method(cMysql2Client, "escape", rb_mysql_client_escape, 1);
  rb_define_method(cMysql2Client, "info", rb_mysql_client_info, 0);
  rb_define_method(cMysql2Client, "server_info", rb_mysql_client_server_info, 0);
  rb_define_method(cMysql2Client, "socket", rb_mysql_client_socket, 0);
  rb_define_method(cMysql2Client, "async_result", rb_mysql_client_async_result, 0);
  rb_define_method(cMysql2Client, "last_id", rb_mysql_client_last_id, 0);
  rb_define_method(cMysql2Client, "affected_rows", rb_mysql_client_affected_rows, 0);

  rb_define_private_method(cMysql2Client, "reconnect=", set_reconnect, 1);
  rb_define_private_method(cMysql2Client, "connect_timeout=", set_connect_timeout, 1);
  rb_define_private_method(cMysql2Client, "charset_name=", set_charset_name, 1);
  rb_define_private_method(cMysql2Client, "ssl_set", set_ssl_options, 5);
  rb_define_private_method(cMysql2Client, "init_connection", init_connection, 0);
  rb_define_private_method(cMysql2Client, "connect", rb_connect, 7);

  intern_encoding_from_charset = rb_intern("encoding_from_charset");

  sym_id              = ID2SYM(rb_intern("id"));
  sym_version         = ID2SYM(rb_intern("version"));
  sym_async           = ID2SYM(rb_intern("async"));
  sym_symbolize_keys  = ID2SYM(rb_intern("symbolize_keys"));
  sym_as              = ID2SYM(rb_intern("as"));
  sym_array           = ID2SYM(rb_intern("array"));

  intern_merge = rb_intern("merge");
  intern_error_number_eql = rb_intern("error_number=");
  intern_sql_state_eql = rb_intern("sql_state=");

#ifdef CLIENT_LONG_PASSWORD
  rb_const_set(cMysql2Client, rb_intern("LONG_PASSWORD"),
      INT2NUM(CLIENT_LONG_PASSWORD));
#endif

#ifdef CLIENT_FOUND_ROWS
  rb_const_set(cMysql2Client, rb_intern("FOUND_ROWS"),
      INT2NUM(CLIENT_FOUND_ROWS));
#endif

#ifdef CLIENT_LONG_FLAG
  rb_const_set(cMysql2Client, rb_intern("LONG_FLAG"),
      INT2NUM(CLIENT_LONG_FLAG));
#endif

#ifdef CLIENT_CONNECT_WITH_DB
  rb_const_set(cMysql2Client, rb_intern("CONNECT_WITH_DB"),
      INT2NUM(CLIENT_CONNECT_WITH_DB));
#endif

#ifdef CLIENT_NO_SCHEMA
  rb_const_set(cMysql2Client, rb_intern("NO_SCHEMA"),
      INT2NUM(CLIENT_NO_SCHEMA));
#endif

#ifdef CLIENT_COMPRESS
  rb_const_set(cMysql2Client, rb_intern("COMPRESS"), INT2NUM(CLIENT_COMPRESS));
#endif

#ifdef CLIENT_ODBC
  rb_const_set(cMysql2Client, rb_intern("ODBC"), INT2NUM(CLIENT_ODBC));
#endif

#ifdef CLIENT_LOCAL_FILES
  rb_const_set(cMysql2Client, rb_intern("LOCAL_FILES"),
      INT2NUM(CLIENT_LOCAL_FILES));
#endif

#ifdef CLIENT_IGNORE_SPACE
  rb_const_set(cMysql2Client, rb_intern("IGNORE_SPACE"),
      INT2NUM(CLIENT_IGNORE_SPACE));
#endif

#ifdef CLIENT_PROTOCOL_41
  rb_const_set(cMysql2Client, rb_intern("PROTOCOL_41"),
      INT2NUM(CLIENT_PROTOCOL_41));
#endif

#ifdef CLIENT_INTERACTIVE
  rb_const_set(cMysql2Client, rb_intern("INTERACTIVE"),
      INT2NUM(CLIENT_INTERACTIVE));
#endif

#ifdef CLIENT_SSL
  rb_const_set(cMysql2Client, rb_intern("SSL"), INT2NUM(CLIENT_SSL));
#endif

#ifdef CLIENT_IGNORE_SIGPIPE
  rb_const_set(cMysql2Client, rb_intern("IGNORE_SIGPIPE"),
      INT2NUM(CLIENT_IGNORE_SIGPIPE));
#endif

#ifdef CLIENT_TRANSACTIONS
  rb_const_set(cMysql2Client, rb_intern("TRANSACTIONS"),
      INT2NUM(CLIENT_TRANSACTIONS));
#endif

#ifdef CLIENT_RESERVED
  rb_const_set(cMysql2Client, rb_intern("RESERVED"), INT2NUM(CLIENT_RESERVED));
#endif

#ifdef CLIENT_SECURE_CONNECTION
  rb_const_set(cMysql2Client, rb_intern("SECURE_CONNECTION"),
      INT2NUM(CLIENT_SECURE_CONNECTION));
#endif

#ifdef CLIENT_MULTI_STATEMENTS
  rb_const_set(cMysql2Client, rb_intern("MULTI_STATEMENTS"),
      INT2NUM(CLIENT_MULTI_STATEMENTS));
#endif

#ifdef CLIENT_PS_MULTI_RESULTS
  rb_const_set(cMysql2Client, rb_intern("PS_MULTI_RESULTS"),
      INT2NUM(CLIENT_PS_MULTI_RESULTS));
#endif

#ifdef CLIENT_SSL_VERIFY_SERVER_CERT
  rb_const_set(cMysql2Client, rb_intern("SSL_VERIFY_SERVER_CERT"),
      INT2NUM(CLIENT_SSL_VERIFY_SERVER_CERT));
#endif

#ifdef CLIENT_REMEMBER_OPTIONS
  rb_const_set(cMysql2Client, rb_intern("REMEMBER_OPTIONS"),
      INT2NUM(CLIENT_REMEMBER_OPTIONS));
#endif

#ifdef CLIENT_ALL_FLAGS
  rb_const_set(cMysql2Client, rb_intern("ALL_FLAGS"),
      INT2NUM(CLIENT_ALL_FLAGS));
#endif

#ifdef CLIENT_BASIC_FLAGS
  rb_const_set(cMysql2Client, rb_intern("BASIC_FLAGS"),
      INT2NUM(CLIENT_BASIC_FLAGS));
#endif
}
