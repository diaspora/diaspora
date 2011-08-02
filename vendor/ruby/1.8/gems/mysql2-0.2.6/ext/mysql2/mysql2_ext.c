#include <mysql2_ext.h>

VALUE mMysql2, cMysql2Error;

/* Ruby Extension initializer */
void Init_mysql2() {
  mMysql2      = rb_define_module("Mysql2");
  cMysql2Error = rb_const_get(mMysql2, rb_intern("Error"));

  init_mysql2_client();
  init_mysql2_result();
}
