#include <ruby.h>
#include <ruby/st.h>
#include <stdlib.h>
#include <assert.h>

#define COVERAGE_DEBUG_EVENTS 0

#define RCOVRT_VERSION_MAJOR 2
#define RCOVRT_VERSION_MINOR 0
#define RCOVRT_VERSION_REV   0

static VALUE mRcov;
static VALUE mRCOV__;
static VALUE oSCRIPT_LINES__;
static ID id_cover;
static st_table* coverinfo = 0;
static char coverage_hook_set_p;

struct cov_array {
  unsigned int len;
  unsigned int *ptr;
};

static struct cov_array *cached_array = 0;
static char *cached_file = 0; 

static struct cov_array * coverage_increase_counter_uncached(char *sourcefile, unsigned int sourceline, char mark_only) {
  struct cov_array *carray = NULL;
 
  if(sourcefile == NULL) {
    /* "can't happen", just ignore and avoid segfault */
    return NULL;
  } 
  else if(!st_lookup(coverinfo, (st_data_t)sourcefile, (st_data_t*)&carray)) {
    VALUE arr;

    arr = rb_hash_aref(oSCRIPT_LINES__, rb_str_new2(sourcefile));
    if(NIL_P(arr)) 
      return 0;
    rb_check_type(arr, T_ARRAY);
    carray = calloc(1, sizeof(struct cov_array));
    carray->ptr = calloc(RARRAY_LEN(arr), sizeof(unsigned int));
    carray->len = RARRAY_LEN(arr);
    st_insert(coverinfo, (st_data_t)strdup(sourcefile), (st_data_t) carray);
  } 
  else {
    /* recovered carray, sanity check */
    assert(carray && "failed to create valid carray");
  }

  if(mark_only) {
    if(!carray->ptr[sourceline])
      carray->ptr[sourceline] = 1;
  } 
  else {
    if (carray && carray->len > sourceline) {
      carray->ptr[sourceline]++;
    }
  }

  return carray;
}

static void coverage_mark_caller() {
  coverage_increase_counter_uncached(rb_sourcefile(), rb_sourceline(), 1);
}

static void coverage_increase_counter_cached(char *sourcefile, int sourceline) {
  if(cached_file == sourcefile && cached_array && cached_array->len > sourceline) {
    cached_array->ptr[sourceline]++;
    return;
  }
  cached_file = sourcefile;
  cached_array = coverage_increase_counter_uncached(sourcefile, sourceline, 0);
}

static void coverage_event_coverage_hook(rb_event_flag_t event, VALUE node, VALUE self, ID mid, VALUE klass) {
  char *sourcefile;
  unsigned int sourceline;
  static unsigned int in_hook = 0;
 
  if(in_hook) {
    return;
  }

  in_hook++;

  #if COVERAGE_DEBUG_EVENTS
  do {
    int status;
    VALUE old_exception;
    old_exception = rb_gv_get("$!");
    rb_protect(rb_inspect, klass, &status);
    if(!status) {
      printf("EVENT: %d %s %s %s %d\n", event,
             klass ? RSTRING(rb_inspect(klass))->ptr : "", 
             mid ? (mid == ID_ALLOCATOR ? "ID_ALLOCATOR" : rb_id2name(mid))
             : "unknown",
             node ? node->nd_file : "", node ? nd_line(node) : 0);
    } 
    else {
      printf("EVENT: %d %s %s %d\n", event,
             mid ? (mid == ID_ALLOCATOR ? "ID_ALLOCATOR" : rb_id2name(mid)) 
             : "unknown",
             node ? node->nd_file : "", node ? nd_line(node) : 0);
    }
    rb_gv_set("$!", old_exception);
  } while (0); 
  #endif

  if(event & RUBY_EVENT_C_CALL) {
    coverage_mark_caller();
  }
  if(event & (RUBY_EVENT_C_CALL | RUBY_EVENT_C_RETURN | RUBY_EVENT_CLASS)) {
    in_hook--;
    return;
  }
  
  sourcefile = rb_sourcefile();
  sourceline = rb_sourceline();
  
  if (0 == sourceline || 0 == sourcefile) {
    in_hook--;
    return;
  }
  
  coverage_increase_counter_cached(sourcefile, sourceline);
  if(event & RUBY_EVENT_CALL)
    coverage_mark_caller();
  in_hook--;
}

static VALUE cov_install_coverage_hook(VALUE self) {
  if(!coverage_hook_set_p) {
    if(!coverinfo)
      coverinfo = st_init_strtable();
    coverage_hook_set_p = 1;
    /* TODO: allow C_CALL too, since it's supported already
     * the overhead is around ~30%, tested on typo */
    VALUE holder = 0;
    rb_add_event_hook(coverage_event_coverage_hook, 
                      RUBY_EVENT_ALL & ~RUBY_EVENT_C_CALL &
                      ~RUBY_EVENT_C_RETURN & ~RUBY_EVENT_CLASS, holder);
    return Qtrue;
  }
  else
    return Qfalse;
}

static int populate_cover(st_data_t key, st_data_t value, st_data_t cover) {
  VALUE rcover;
  VALUE rkey;
  VALUE rval;
  struct cov_array *carray;
  unsigned int i;
  
  rcover = (VALUE)cover;
  carray = (struct cov_array *) value;
  rkey = rb_str_new2((char*) key);
  rval = rb_ary_new2(carray->len);
  for(i = 0; i < carray->len; i++)
    rb_ary_push(rval, UINT2NUM(carray->ptr[i]));
  
  rb_hash_aset(rcover, rkey, rval);
  
  return ST_CONTINUE;
}

static int free_table(st_data_t key, st_data_t value, st_data_t ignored) {
  struct cov_array *carray;
  
  carray = (struct cov_array *) value;
  free((char *)key);
  free(carray->ptr);
  free(carray);
  
  return ST_CONTINUE;
}

static VALUE cov_remove_coverage_hook(VALUE self) {
  if(!coverage_hook_set_p) 
    return Qfalse;
  else {
    rb_remove_event_hook(coverage_event_coverage_hook);
    coverage_hook_set_p = 0;
    return Qtrue;
  }
}

static VALUE cov_generate_coverage_info(VALUE self) {
  VALUE cover;

  if(rb_const_defined_at(mRCOV__, id_cover)) {
    rb_mod_remove_const(mRCOV__, ID2SYM(id_cover));
  }

  cover = rb_hash_new();
  if(coverinfo)
    st_foreach(coverinfo, populate_cover, cover);
  rb_define_const(mRCOV__, "COVER", cover);

  return cover;
}

static VALUE cov_reset_coverage(VALUE self) {
  if(coverage_hook_set_p) {
    rb_raise(rb_eRuntimeError, "Cannot reset the coverage info in the middle of a traced run.");
    return Qnil;
  }

  cached_array = 0;
  cached_file = 0;
  st_foreach(coverinfo, free_table, Qnil); 
  st_free_table(coverinfo);
  coverinfo = 0;

  return Qnil;
}

static VALUE cov_ABI(VALUE self) {
  VALUE ret;

  ret = rb_ary_new();
  rb_ary_push(ret, INT2FIX(RCOVRT_VERSION_MAJOR));
  rb_ary_push(ret, INT2FIX(RCOVRT_VERSION_MINOR));
  rb_ary_push(ret, INT2FIX(RCOVRT_VERSION_REV));

  return ret;
}

void Init_rcovrt() {
  ID id_rcov = rb_intern("Rcov");
  ID id_coverage__ = rb_intern("RCOV__");
  ID id_script_lines__ = rb_intern("SCRIPT_LINES__");
  
  id_cover = rb_intern("COVER");
  
  if(rb_const_defined(rb_cObject, id_rcov)) 
    mRcov = rb_const_get(rb_cObject, id_rcov);
  else
    mRcov = rb_define_module("Rcov");
  
  if(rb_const_defined(mRcov, id_coverage__))
    mRCOV__ = rb_const_get_at(mRcov, id_coverage__);
  else
    mRCOV__ = rb_define_module_under(mRcov, "RCOV__");
  
  if(rb_const_defined(rb_cObject, id_script_lines__))
    oSCRIPT_LINES__ = rb_const_get(rb_cObject, rb_intern("SCRIPT_LINES__"));
  else {
    oSCRIPT_LINES__ = rb_hash_new();
    rb_const_set(rb_cObject, id_script_lines__, oSCRIPT_LINES__);
  }
  
  coverage_hook_set_p = 0;
  
  rb_define_singleton_method(mRCOV__, "install_coverage_hook", cov_install_coverage_hook, 0);
  rb_define_singleton_method(mRCOV__, "remove_coverage_hook", cov_remove_coverage_hook, 0);
  rb_define_singleton_method(mRCOV__, "generate_coverage_info", cov_generate_coverage_info, 0);
  rb_define_singleton_method(mRCOV__, "reset_coverage", cov_reset_coverage, 0);
  rb_define_singleton_method(mRCOV__, "ABI", cov_ABI, 0);
  
  Init_rcov_callsite();
}
