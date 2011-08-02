#include <mysql2_ext.h>

#ifdef HAVE_RUBY_ENCODING_H
rb_encoding *binaryEncoding;
#endif

VALUE cMysql2Result;
VALUE cBigDecimal, cDate, cDateTime;
VALUE opt_decimal_zero, opt_float_zero, opt_time_year, opt_time_month, opt_utc_offset;
extern VALUE mMysql2, cMysql2Client, cMysql2Error;
static VALUE intern_encoding_from_charset;
static ID intern_new, intern_utc, intern_local, intern_encoding_from_charset_code,
          intern_localtime, intern_local_offset, intern_civil, intern_new_offset;
static ID sym_symbolize_keys, sym_as, sym_array, sym_database_timezone, sym_application_timezone,
          sym_local, sym_utc, sym_cast_booleans, sym_cache_rows;
static ID intern_merge;

static void rb_mysql_result_mark(void * wrapper) {
  mysql2_result_wrapper * w = wrapper;
  if (w) {
    rb_gc_mark(w->fields);
    rb_gc_mark(w->rows);
    rb_gc_mark(w->encoding);
  }
}

/* this may be called manually or during GC */
static void rb_mysql_result_free_result(mysql2_result_wrapper * wrapper) {
  if (wrapper && wrapper->resultFreed != 1) {
    mysql_free_result(wrapper->result);
    wrapper->resultFreed = 1;
  }
}

/* this is called during GC */
static void rb_mysql_result_free(void * wrapper) {
  mysql2_result_wrapper * w = wrapper;
  /* FIXME: this may call flush_use_result, which can hit the socket */
  rb_mysql_result_free_result(w);
  xfree(wrapper);
}

/*
 * for small results, this won't hit the network, but there's no
 * reliable way for us to tell this so we'll always release the GVL
 * to be safe
 */
static VALUE nogvl_fetch_row(void *ptr) {
  MYSQL_RES *result = ptr;

  return (VALUE)mysql_fetch_row(result);
}

static VALUE rb_mysql_result_fetch_field(VALUE self, unsigned int idx, short int symbolize_keys) {
  mysql2_result_wrapper * wrapper;

  GetMysql2Result(self, wrapper);

  if (wrapper->fields == Qnil) {
    wrapper->numberOfFields = mysql_num_fields(wrapper->result);
    wrapper->fields = rb_ary_new2(wrapper->numberOfFields);
  }

  VALUE rb_field = rb_ary_entry(wrapper->fields, idx);
  if (rb_field == Qnil) {
    MYSQL_FIELD *field = NULL;
#ifdef HAVE_RUBY_ENCODING_H
    rb_encoding *default_internal_enc = rb_default_internal_encoding();
    rb_encoding *conn_enc = rb_to_encoding(wrapper->encoding);
#endif

    field = mysql_fetch_field_direct(wrapper->result, idx);
    if (symbolize_keys) {
      char buf[field->name_length+1];
      memcpy(buf, field->name, field->name_length);
      buf[field->name_length] = 0;
      rb_field = ID2SYM(rb_intern(buf));
    } else {
      rb_field = rb_str_new(field->name, field->name_length);
#ifdef HAVE_RUBY_ENCODING_H
      rb_enc_associate(rb_field, conn_enc);
      if (default_internal_enc) {
        rb_field = rb_str_export_to_enc(rb_field, default_internal_enc);
      }
#endif
    }
    rb_ary_store(wrapper->fields, idx, rb_field);
  }

  return rb_field;
}

static VALUE rb_mysql_result_fetch_row(VALUE self, ID db_timezone, ID app_timezone, int symbolizeKeys, int asArray, int castBool) {
  VALUE rowVal;
  mysql2_result_wrapper * wrapper;
  MYSQL_ROW row;
  MYSQL_FIELD * fields = NULL;
  unsigned int i = 0;
  unsigned long * fieldLengths;
  void * ptr;

  GetMysql2Result(self, wrapper);

#ifdef HAVE_RUBY_ENCODING_H
  rb_encoding *default_internal_enc = rb_default_internal_encoding();
  rb_encoding *conn_enc = rb_to_encoding(wrapper->encoding);
#endif

  ptr = wrapper->result;
  row = (MYSQL_ROW)rb_thread_blocking_region(nogvl_fetch_row, ptr, RUBY_UBF_IO, 0);
  if (row == NULL) {
    return Qnil;
  }

  if (asArray) {
    rowVal = rb_ary_new2(wrapper->numberOfFields);
  } else {
    rowVal = rb_hash_new();
  }
  fields = mysql_fetch_fields(wrapper->result);
  fieldLengths = mysql_fetch_lengths(wrapper->result);
  if (wrapper->fields == Qnil) {
    wrapper->numberOfFields = mysql_num_fields(wrapper->result);
    wrapper->fields = rb_ary_new2(wrapper->numberOfFields);
  }

  for (i = 0; i < wrapper->numberOfFields; i++) {
    VALUE field = rb_mysql_result_fetch_field(self, i, symbolizeKeys);
    if (row[i]) {
      VALUE val = Qnil;
      switch(fields[i].type) {
        case MYSQL_TYPE_NULL:       // NULL-type field
          val = Qnil;
          break;
        case MYSQL_TYPE_BIT:        // BIT field (MySQL 5.0.3 and up)
          val = rb_str_new(row[i], fieldLengths[i]);
          break;
        case MYSQL_TYPE_TINY:       // TINYINT field
          if (castBool && fields[i].length == 1) {
            val = *row[i] == '1' ? Qtrue : Qfalse;
            break;
          }
        case MYSQL_TYPE_SHORT:      // SMALLINT field
        case MYSQL_TYPE_LONG:       // INTEGER field
        case MYSQL_TYPE_INT24:      // MEDIUMINT field
        case MYSQL_TYPE_LONGLONG:   // BIGINT field
        case MYSQL_TYPE_YEAR:       // YEAR field
          val = rb_cstr2inum(row[i], 10);
          break;
        case MYSQL_TYPE_DECIMAL:    // DECIMAL or NUMERIC field
        case MYSQL_TYPE_NEWDECIMAL: // Precision math DECIMAL or NUMERIC field (MySQL 5.0.3 and up)
          if (strtod(row[i], NULL) == 0.000000){
            val = rb_funcall(cBigDecimal, intern_new, 1, opt_decimal_zero);
          }else{
            val = rb_funcall(cBigDecimal, intern_new, 1, rb_str_new(row[i], fieldLengths[i]));
          }
          break;
        case MYSQL_TYPE_FLOAT:      // FLOAT field
        case MYSQL_TYPE_DOUBLE: {     // DOUBLE or REAL field
          double column_to_double;
          column_to_double = strtod(row[i], NULL);
          if (column_to_double == 0.000000){
            val = opt_float_zero;
          }else{
            val = rb_float_new(column_to_double);
          }
          break;
        }
        case MYSQL_TYPE_TIME: {     // TIME field
          int hour, min, sec, tokens;
          tokens = sscanf(row[i], "%2d:%2d:%2d", &hour, &min, &sec);
          val = rb_funcall(rb_cTime, db_timezone, 6, opt_time_year, opt_time_month, opt_time_month, INT2NUM(hour), INT2NUM(min), INT2NUM(sec));
          if (!NIL_P(app_timezone)) {
            if (app_timezone == intern_local) {
              val = rb_funcall(val, intern_localtime, 0);
            } else { // utc
              val = rb_funcall(val, intern_utc, 0);
            }
          }
          break;
        }
        case MYSQL_TYPE_TIMESTAMP:  // TIMESTAMP field
        case MYSQL_TYPE_DATETIME: { // DATETIME field
          int year, month, day, hour, min, sec, tokens;
          tokens = sscanf(row[i], "%4d-%2d-%2d %2d:%2d:%2d", &year, &month, &day, &hour, &min, &sec);
          if (year+month+day+hour+min+sec == 0) {
            val = Qnil;
          } else {
            if (month < 1 || day < 1) {
              rb_raise(cMysql2Error, "Invalid date: %s", row[i]);
              val = Qnil;
            } else {
              if (year < 1902 || year+month+day > 2058) { // use DateTime instead
                VALUE offset = INT2NUM(0);
                if (db_timezone == intern_local) {
                  offset = rb_funcall(cMysql2Client, intern_local_offset, 0);
                }
                val = rb_funcall(cDateTime, intern_civil, 7, INT2NUM(year), INT2NUM(month), INT2NUM(day), INT2NUM(hour), INT2NUM(min), INT2NUM(sec), offset);
                if (!NIL_P(app_timezone)) {
                  if (app_timezone == intern_local) {
                    offset = rb_funcall(cMysql2Client, intern_local_offset, 0);
                    val = rb_funcall(val, intern_new_offset, 1, offset);
                  } else { // utc
                    val = rb_funcall(val, intern_new_offset, 1, opt_utc_offset);
                  }
                }
              } else {
                val = rb_funcall(rb_cTime, db_timezone, 6, INT2NUM(year), INT2NUM(month), INT2NUM(day), INT2NUM(hour), INT2NUM(min), INT2NUM(sec));
                if (!NIL_P(app_timezone)) {
                  if (app_timezone == intern_local) {
                    val = rb_funcall(val, intern_localtime, 0);
                  } else { // utc
                    val = rb_funcall(val, intern_utc, 0);
                  }
                }
              }
            }
          }
          break;
        }
        case MYSQL_TYPE_DATE:       // DATE field
        case MYSQL_TYPE_NEWDATE: {  // Newer const used > 5.0
          int year, month, day, tokens;
          tokens = sscanf(row[i], "%4d-%2d-%2d", &year, &month, &day);
          if (year+month+day == 0) {
            val = Qnil;
          } else {
            if (month < 1 || day < 1) {
              rb_raise(cMysql2Error, "Invalid date: %s", row[i]);
              val = Qnil;
            } else {
              val = rb_funcall(cDate, intern_new, 3, INT2NUM(year), INT2NUM(month), INT2NUM(day));
            }
          }
          break;
        }
        case MYSQL_TYPE_TINY_BLOB:
        case MYSQL_TYPE_MEDIUM_BLOB:
        case MYSQL_TYPE_LONG_BLOB:
        case MYSQL_TYPE_BLOB:
        case MYSQL_TYPE_VAR_STRING:
        case MYSQL_TYPE_VARCHAR:
        case MYSQL_TYPE_STRING:     // CHAR or BINARY field
        case MYSQL_TYPE_SET:        // SET field
        case MYSQL_TYPE_ENUM:       // ENUM field
        case MYSQL_TYPE_GEOMETRY:   // Spatial fielda
        default:
          val = rb_str_new(row[i], fieldLengths[i]);
#ifdef HAVE_RUBY_ENCODING_H
          // if binary flag is set, respect it's wishes
          if (fields[i].flags & BINARY_FLAG) {
            rb_enc_associate(val, binaryEncoding);
          } else {
            // lookup the encoding configured on this field
            VALUE new_encoding = rb_funcall(cMysql2Client, intern_encoding_from_charset_code, 1, INT2NUM(fields[i].charsetnr));
            if (new_encoding != Qnil) {
              // use the field encoding we were able to match
              rb_encoding *enc = rb_to_encoding(new_encoding);
              rb_enc_associate(val, enc);
            } else {
              // otherwise fall-back to the connection's encoding
              rb_enc_associate(val, conn_enc);
            }
            if (default_internal_enc) {
              val = rb_str_export_to_enc(val, default_internal_enc);
            }
          }
#endif
          break;
      }
      if (asArray) {
        rb_ary_push(rowVal, val);
      } else {
        rb_hash_aset(rowVal, field, val);
      }
    } else {
      if (asArray) {
        rb_ary_push(rowVal, Qnil);
      } else {
        rb_hash_aset(rowVal, field, Qnil);
      }
    }
  }
  return rowVal;
}

static VALUE rb_mysql_result_fetch_fields(VALUE self) {
  mysql2_result_wrapper * wrapper;
  unsigned int i = 0;
  short int symbolizeKeys = 0;
  VALUE defaults;

  GetMysql2Result(self, wrapper);

  defaults = rb_iv_get(self, "@query_options");
  if (rb_hash_aref(defaults, sym_symbolize_keys) == Qtrue) {
    symbolizeKeys = 1;
  }

  if (wrapper->fields == Qnil) {
    wrapper->numberOfFields = mysql_num_fields(wrapper->result);
    wrapper->fields = rb_ary_new2(wrapper->numberOfFields);
  }

  if (RARRAY_LEN(wrapper->fields) != wrapper->numberOfFields) {
    for (i=0; i<wrapper->numberOfFields; i++) {
      rb_mysql_result_fetch_field(self, i, symbolizeKeys);
    }
  }

  return wrapper->fields;
}

static VALUE rb_mysql_result_each(int argc, VALUE * argv, VALUE self) {
  VALUE defaults, opts, block;
  ID db_timezone, app_timezone, dbTz, appTz;
  mysql2_result_wrapper * wrapper;
  unsigned long i;
  int symbolizeKeys = 0, asArray = 0, castBool = 0, cacheRows = 1;

  GetMysql2Result(self, wrapper);

  defaults = rb_iv_get(self, "@query_options");
  if (rb_scan_args(argc, argv, "01&", &opts, &block) == 1) {
    opts = rb_funcall(defaults, intern_merge, 1, opts);
  } else {
    opts = defaults;
  }

  if (rb_hash_aref(opts, sym_symbolize_keys) == Qtrue) {
    symbolizeKeys = 1;
  }

  if (rb_hash_aref(opts, sym_as) == sym_array) {
    asArray = 1;
  }

  if (rb_hash_aref(opts, sym_cast_booleans) == Qtrue) {
    castBool = 1;
  }

  if (rb_hash_aref(opts, sym_cache_rows) == Qfalse) {
    cacheRows = 0;
  }

  dbTz = rb_hash_aref(opts, sym_database_timezone);
  if (dbTz == sym_local) {
    db_timezone = intern_local;
  } else if (dbTz == sym_utc) {
    db_timezone = intern_utc;
  } else {
    if (!NIL_P(dbTz)) {
      rb_warn(":database_timezone option must be :utc or :local - defaulting to :local");
    }
    db_timezone = intern_local;
  }

  appTz = rb_hash_aref(opts, sym_application_timezone);
  if (appTz == sym_local) {
    app_timezone = intern_local;
  } else if (appTz == sym_utc) {
    app_timezone = intern_utc;
  } else {
    app_timezone = Qnil;
  }

  if (wrapper->lastRowProcessed == 0) {
    wrapper->numberOfRows = mysql_num_rows(wrapper->result);
    if (wrapper->numberOfRows == 0) {
      wrapper->rows = rb_ary_new();
      return wrapper->rows;
    }
    wrapper->rows = rb_ary_new2(wrapper->numberOfRows);
  }

  if (cacheRows && wrapper->lastRowProcessed == wrapper->numberOfRows) {
    // we've already read the entire dataset from the C result into our
    // internal array. Lets hand that over to the user since it's ready to go
    for (i = 0; i < wrapper->numberOfRows; i++) {
      rb_yield(rb_ary_entry(wrapper->rows, i));
    }
  } else {
    unsigned long rowsProcessed = 0;
    rowsProcessed = RARRAY_LEN(wrapper->rows);
    for (i = 0; i < wrapper->numberOfRows; i++) {
      VALUE row;
      if (cacheRows && i < rowsProcessed) {
        row = rb_ary_entry(wrapper->rows, i);
      } else {
        row = rb_mysql_result_fetch_row(self, db_timezone, app_timezone, symbolizeKeys, asArray, castBool);
        if (cacheRows) {
          rb_ary_store(wrapper->rows, i, row);
        }
        wrapper->lastRowProcessed++;
      }

      if (row == Qnil) {
        // we don't need the mysql C dataset around anymore, peace it
        rb_mysql_result_free_result(wrapper);
        return Qnil;
      }

      if (block != Qnil) {
        rb_yield(row);
      }
    }
    if (wrapper->lastRowProcessed == wrapper->numberOfRows) {
      // we don't need the mysql C dataset around anymore, peace it
      rb_mysql_result_free_result(wrapper);
    }
  }

  return wrapper->rows;
}

/* Mysql2::Result */
VALUE rb_mysql_result_to_obj(MYSQL_RES * r) {
  VALUE obj;
  mysql2_result_wrapper * wrapper;
  obj = Data_Make_Struct(cMysql2Result, mysql2_result_wrapper, rb_mysql_result_mark, rb_mysql_result_free, wrapper);
  wrapper->numberOfFields = 0;
  wrapper->numberOfRows = 0;
  wrapper->lastRowProcessed = 0;
  wrapper->resultFreed = 0;
  wrapper->result = r;
  wrapper->fields = Qnil;
  wrapper->rows = Qnil;
  wrapper->encoding = Qnil;
  rb_obj_call_init(obj, 0, NULL);
  return obj;
}

void init_mysql2_result() {
  cBigDecimal = rb_const_get(rb_cObject, rb_intern("BigDecimal"));
  cDate = rb_const_get(rb_cObject, rb_intern("Date"));
  cDateTime = rb_const_get(rb_cObject, rb_intern("DateTime"));

  cMysql2Result = rb_define_class_under(mMysql2, "Result", rb_cObject);
  rb_define_method(cMysql2Result, "each", rb_mysql_result_each, -1);
  rb_define_method(cMysql2Result, "fields", rb_mysql_result_fetch_fields, 0);

  intern_encoding_from_charset = rb_intern("encoding_from_charset");
  intern_encoding_from_charset_code = rb_intern("encoding_from_charset_code");

  intern_new          = rb_intern("new");
  intern_utc          = rb_intern("utc");
  intern_local        = rb_intern("local");
  intern_merge        = rb_intern("merge");
  intern_localtime    = rb_intern("localtime");
  intern_local_offset = rb_intern("local_offset");
  intern_civil        = rb_intern("civil");
  intern_new_offset   = rb_intern("new_offset");

  sym_symbolize_keys  = ID2SYM(rb_intern("symbolize_keys"));
  sym_as              = ID2SYM(rb_intern("as"));
  sym_array           = ID2SYM(rb_intern("array"));
  sym_local           = ID2SYM(rb_intern("local"));
  sym_utc             = ID2SYM(rb_intern("utc"));
  sym_cast_booleans   = ID2SYM(rb_intern("cast_booleans"));
  sym_database_timezone     = ID2SYM(rb_intern("database_timezone"));
  sym_application_timezone  = ID2SYM(rb_intern("application_timezone"));
  sym_cache_rows     = ID2SYM(rb_intern("cache_rows"));

  opt_decimal_zero = rb_str_new2("0.0");
  rb_global_variable(&opt_decimal_zero); //never GC
  opt_float_zero = rb_float_new((double)0);
  rb_global_variable(&opt_float_zero);
  opt_time_year = INT2NUM(2000);
  opt_time_month = INT2NUM(1);
  opt_utc_offset = INT2NUM(0);

#ifdef HAVE_RUBY_ENCODING_H
  binaryEncoding = rb_enc_find("binary");
#endif
}
