#ifndef MYSQL2_RESULT_H
#define MYSQL2_RESULT_H

void init_mysql2_result();
VALUE rb_mysql_result_to_obj(MYSQL_RES * r);

typedef struct {
  VALUE fields;
  VALUE rows;
  VALUE encoding;
  long numberOfFields;
  unsigned long numberOfRows;
  unsigned long lastRowProcessed;
  short int resultFreed;
  MYSQL_RES *result;
} mysql2_result_wrapper;

#define GetMysql2Result(obj, sval) (sval = (mysql2_result_wrapper*)DATA_PTR(obj));

#endif
