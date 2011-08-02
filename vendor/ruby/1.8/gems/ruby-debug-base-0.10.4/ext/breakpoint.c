#include "ruby_debug.h"

VALUE rdebug_breakpoints = Qnil;
VALUE rdebug_catchpoints;

static VALUE cBreakpoint;
static ID    idEval;

static VALUE
eval_expression(VALUE args)
{
    return rb_funcall2(rb_mKernel, idEval, 2, RARRAY(args)->ptr);
}

int
check_breakpoint_hit_condition(VALUE breakpoint)
{
    debug_breakpoint_t *debug_breakpoint;
    
    if(breakpoint == Qnil)
        return 0;
    Data_Get_Struct(breakpoint, debug_breakpoint_t, debug_breakpoint);

    debug_breakpoint->hit_count++;
    if (!Qtrue == debug_breakpoint->enabled) return 0;
    switch(debug_breakpoint->hit_condition)
    {
        case HIT_COND_NONE:
            return 1;
        case HIT_COND_GE:
        {
            if(debug_breakpoint->hit_count >= debug_breakpoint->hit_value)
                return 1;
            break;
        }
        case HIT_COND_EQ:
        {
            if(debug_breakpoint->hit_count == debug_breakpoint->hit_value)
                return 1;
            break;
        }
        case HIT_COND_MOD:
        {
            if(debug_breakpoint->hit_count % debug_breakpoint->hit_value == 0)
                return 1;
            break;
        }
    }
    return 0;
}

static int
check_breakpoint_by_pos(VALUE breakpoint, char *file, int line)
{
    debug_breakpoint_t *debug_breakpoint;

    if(breakpoint == Qnil)
        return 0;
    Data_Get_Struct(breakpoint, debug_breakpoint_t, debug_breakpoint);
    if (!Qtrue == debug_breakpoint->enabled) return 0;
    if(debug_breakpoint->type != BP_POS_TYPE)
        return 0;
    if(debug_breakpoint->pos.line != line)
        return 0;
    if(filename_cmp(debug_breakpoint->source, file))
        return 1;
    return 0;
}

int
check_breakpoint_by_method(VALUE breakpoint, VALUE klass, ID mid, VALUE self)
{
    debug_breakpoint_t *debug_breakpoint;

    if(breakpoint == Qnil)
        return 0;
    Data_Get_Struct(breakpoint, debug_breakpoint_t, debug_breakpoint);
    if (!Qtrue == debug_breakpoint->enabled) return 0;
    if(debug_breakpoint->type != BP_METHOD_TYPE)
        return 0;
    if(debug_breakpoint->pos.mid != mid)
        return 0;
    if(classname_cmp(debug_breakpoint->source, klass))
        return 1;
    if ((rb_type(self) == T_CLASS) &&
        classname_cmp(debug_breakpoint->source, self))
        return 1;
    return 0;
}

VALUE
check_breakpoints_by_pos(debug_context_t *debug_context, char *file, int line)
{
    VALUE breakpoint;
    int i;

    if(!CTX_FL_TEST(debug_context, CTX_FL_ENABLE_BKPT))
        return Qnil;
    
    if(check_breakpoint_by_pos(debug_context->breakpoint, file, line))
        return debug_context->breakpoint;

    if(RARRAY(rdebug_breakpoints)->len == 0)
        return Qnil;
    for(i = 0; i < RARRAY(rdebug_breakpoints)->len; i++)
    {
        breakpoint = rb_ary_entry(rdebug_breakpoints, i);
        if(check_breakpoint_by_pos(breakpoint, file, line))
            return breakpoint;
    }
    return Qnil;
}

VALUE
check_breakpoints_by_method(debug_context_t *debug_context, VALUE klass, ID mid, VALUE self)
{
    VALUE breakpoint;
    int i;

    if(!CTX_FL_TEST(debug_context, CTX_FL_ENABLE_BKPT))
        return Qnil;
        
    if(check_breakpoint_by_method(debug_context->breakpoint, klass, mid, self))
        return debug_context->breakpoint;

    if(RARRAY(rdebug_breakpoints)->len == 0)
        return Qnil;
    for(i = 0; i < RARRAY(rdebug_breakpoints)->len; i++)
    {
        breakpoint = rb_ary_entry(rdebug_breakpoints, i);
        if(check_breakpoint_by_method(breakpoint, klass, mid, self))
            return breakpoint;
    }
    return Qnil;
}

int
check_breakpoint_expression(VALUE breakpoint, VALUE binding)
{
    debug_breakpoint_t *debug_breakpoint;
    VALUE args, expr_result;

    Data_Get_Struct(breakpoint, debug_breakpoint_t, debug_breakpoint);
    if(NIL_P(debug_breakpoint->expr))
        return 1;

    args = rb_ary_new3(2, debug_breakpoint->expr, binding);
    expr_result = rb_protect(eval_expression, args, 0);
    return RTEST(expr_result);
}

static void
breakpoint_mark(void *data)
{
    debug_breakpoint_t *breakpoint;
    breakpoint = (debug_breakpoint_t *)data;
    rb_gc_mark(breakpoint->source);
    rb_gc_mark(breakpoint->expr);
}

VALUE
create_breakpoint_from_args(int argc, VALUE *argv, int id)
{
    VALUE source, pos, expr;
    debug_breakpoint_t *breakpoint;
    int type;

    if(rb_scan_args(argc, argv, "21", &source, &pos, &expr) == 2)
    {
        expr = Qnil;
    }
    type = FIXNUM_P(pos) ? BP_POS_TYPE : BP_METHOD_TYPE;
    if(type == BP_POS_TYPE)
        source = StringValue(source);
    else
        pos = StringValue(pos);
    breakpoint = ALLOC(debug_breakpoint_t);
    breakpoint->id = id;
    breakpoint->source = source;
    breakpoint->type = type;
    if(type == BP_POS_TYPE)
        breakpoint->pos.line = FIX2INT(pos);
    else
        breakpoint->pos.mid = rb_intern(RSTRING(pos)->ptr);
    breakpoint->enabled = Qtrue;
    breakpoint->expr = NIL_P(expr) ? expr: StringValue(expr);
    breakpoint->hit_count = 0;
    breakpoint->hit_value = 0;
    breakpoint->hit_condition = HIT_COND_NONE;
    return Data_Wrap_Struct(cBreakpoint, breakpoint_mark, xfree, breakpoint);
}

/*
 *   call-seq:
 *      Debugger.remove_breakpoint(id) -> breakpoint
 *
 *   Removes breakpoint by its id.
 *   <i>id</i> is an identificator of a breakpoint.
 */
VALUE
rdebug_remove_breakpoint(VALUE self, VALUE id_value)
{
    int i;
    int id;
    VALUE breakpoint;
    debug_breakpoint_t *debug_breakpoint;

    id = FIX2INT(id_value);

    for( i = 0; i < RARRAY(rdebug_breakpoints)->len; i += 1 )
    {
        breakpoint = rb_ary_entry(rdebug_breakpoints, i);
        Data_Get_Struct(breakpoint, debug_breakpoint_t, debug_breakpoint);
        if(debug_breakpoint->id == id)
        {
            rb_ary_delete_at(rdebug_breakpoints, i);
            return breakpoint;
        }
    }
    return Qnil;
}

/*
 *   call-seq:
 *      Debugger.catchpoints -> hash
 *
 *   Returns a current catchpoints, which is a hash exception names that will
 *   trigger a debugger when raised. The values are the number of times taht
 *   catchpoint was hit, initially 0.
 */
VALUE
debug_catchpoints(VALUE self)
{
    debug_check_started();

    return rdebug_catchpoints;
}

/*
 *   call-seq:
 *      Debugger.catchpoint(string) -> string
 *
 *   Sets catchpoint. Returns the string passed.
 */
VALUE
rdebug_add_catchpoint(VALUE self, VALUE value)
{
    debug_check_started();

    if (TYPE(value) != T_STRING) {
        rb_raise(rb_eTypeError, "value of a catchpoint must be String");
    }
    rb_hash_aset(rdebug_catchpoints, rb_str_dup(value), INT2FIX(0));
    return value;
}

/*
 *   call-seq:
 *      context.breakpoint -> Breakpoint
 *
 *   Returns a context-specific temporary Breakpoint object.
 */
VALUE
context_breakpoint(VALUE self)
{
    debug_context_t *debug_context;

    debug_check_started();

    Data_Get_Struct(self, debug_context_t, debug_context);
    return debug_context->breakpoint;
}

/*
 *   call-seq:
 *      context.set_breakpoint(source, pos, condition = nil) -> breakpoint
 *
 *   Sets a context-specific temporary breakpoint, which can be used to implement
 *   'Run to Cursor' debugger function. When this breakpoint is reached, it will be
 *   cleared out.
 *
 *   <i>source</i> is a name of a file or a class.
 *   <i>pos</i> is a line number or a method name if <i>source</i> is a class name.
 *   <i>condition</i> is a string which is evaluated to +true+ when this breakpoint
 *   is activated.
 */
VALUE
context_set_breakpoint(int argc, VALUE *argv, VALUE self)
{
    VALUE result;
    debug_context_t *debug_context;

    debug_check_started();

    Data_Get_Struct(self, debug_context_t, debug_context);
    result = create_breakpoint_from_args(argc, argv, 0);
    debug_context->breakpoint = result;
    return result;
}

/*
 *   call-seq:
 *      breakpoint.enabled?
 *
 *   Returns whether breakpoint is enabled or not.
 */
static VALUE
breakpoint_enabled(VALUE self)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    return breakpoint->enabled;
}

/*
 *   call-seq:
 *      breakpoint.enabled = bool
 *
 *   Enables or disables breakpoint.
 */
static VALUE
breakpoint_set_enabled(VALUE self, VALUE bool)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    return breakpoint->enabled = bool;
}

/*
 *   call-seq:
 *      breakpoint.source -> string
 *
 *   Returns a source of the breakpoint.
 */
static VALUE
breakpoint_source(VALUE self)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    return breakpoint->source;
}

/*
 *   call-seq:
 *      breakpoint.source = string
 *
 *   Sets the source of the breakpoint.
 */
static VALUE
breakpoint_set_source(VALUE self, VALUE value)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    breakpoint->source = StringValue(value);
    return value;
}

/*
 *   call-seq:
 *      breakpoint.pos -> string or int
 *
 *   Returns the position of this breakpoint.
 */
static VALUE
breakpoint_pos(VALUE self)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    if(breakpoint->type == BP_METHOD_TYPE)
        return rb_str_new2(rb_id2name(breakpoint->pos.mid));
    else
        return INT2FIX(breakpoint->pos.line);
}

/*
 *   call-seq:
 *      breakpoint.pos = string or int
 *
 *   Sets the position of this breakpoint.
 */
static VALUE
breakpoint_set_pos(VALUE self, VALUE value)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    if(breakpoint->type == BP_METHOD_TYPE)
    {
        breakpoint->pos.mid = rb_to_id(StringValue(value));
    }
    else
        breakpoint->pos.line = FIX2INT(value);
    return value;
}

/*
 *   call-seq:
 *      breakpoint.expr -> string
 *
 *   Returns a codition expression when this breakpoint should be activated.
 */
static VALUE
breakpoint_expr(VALUE self)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    return breakpoint->expr;
}

/*
 *   call-seq:
 *      breakpoint.expr = string | nil
 *
 *   Sets the codition expression when this breakpoint should be activated.
 */
static VALUE
breakpoint_set_expr(VALUE self, VALUE expr)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    breakpoint->expr = NIL_P(expr) ? expr: StringValue(expr);
    return expr;
}

/*
 *   call-seq:
 *      breakpoint.id -> int
 *
 *   Returns id of the breakpoint.
 */
static VALUE
breakpoint_id(VALUE self)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    return INT2FIX(breakpoint->id);
}

/*
 *   call-seq:
 *      breakpoint.hit_count -> int
 *
 *   Returns the hit count of the breakpoint.
 */
static VALUE
breakpoint_hit_count(VALUE self)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    return INT2FIX(breakpoint->hit_count);
}

/*
 *   call-seq:
 *      breakpoint.hit_value -> int
 *
 *   Returns the hit value of the breakpoint.
 */
static VALUE
breakpoint_hit_value(VALUE self)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    return INT2FIX(breakpoint->hit_value);
}

/*
 *   call-seq:
 *      breakpoint.hit_value = int
 *
 *   Sets the hit value of the breakpoint.
 */
static VALUE
breakpoint_set_hit_value(VALUE self, VALUE value)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    breakpoint->hit_value = FIX2INT(value);
    return value;
}

/*
 *   call-seq:
 *      breakpoint.hit_condition -> symbol
 *
 *   Returns the hit condition of the breakpoint:
 *
 *   +nil+ if it is an unconditional breakpoint, or
 *   :greater_or_equal, :equal, :modulo
 */
static VALUE
breakpoint_hit_condition(VALUE self)
{
    debug_breakpoint_t *breakpoint;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    switch(breakpoint->hit_condition)
    {
        case HIT_COND_GE:
            return ID2SYM(rb_intern("greater_or_equal"));
        case HIT_COND_EQ:
            return ID2SYM(rb_intern("equal"));
        case HIT_COND_MOD:
            return ID2SYM(rb_intern("modulo"));
        case HIT_COND_NONE:
        default:
            return Qnil;
    }
}

/*
 *   call-seq:
 *      breakpoint.hit_condition = symbol
 *
 *   Sets the hit condition of the breakpoint which must be one of the following values:
 *
 *   +nil+ if it is an unconditional breakpoint, or
 *   :greater_or_equal(:ge), :equal(:eq), :modulo(:mod)
 */
static VALUE
breakpoint_set_hit_condition(VALUE self, VALUE value)
{
    debug_breakpoint_t *breakpoint;
    ID id_value;

    Data_Get_Struct(self, debug_breakpoint_t, breakpoint);
    id_value = rb_to_id(value);
    
    if(rb_intern("greater_or_equal") == id_value || rb_intern("ge") == id_value)
        breakpoint->hit_condition = HIT_COND_GE;
    else if(rb_intern("equal") == id_value || rb_intern("eq") == id_value)
        breakpoint->hit_condition = HIT_COND_EQ;
    else if(rb_intern("modulo") == id_value || rb_intern("mod") == id_value)
        breakpoint->hit_condition = HIT_COND_MOD;
    else
        rb_raise(rb_eArgError, "Invalid condition parameter");
    return value;
}

/*
 *   Document-class: Breakpoint
 *
 *   == Summary
 *
 *   This class represents a breakpoint. It defines position of the breakpoint and
 *   condition when this breakpoint should be triggered.
 */
void
Init_breakpoint()
{
    cBreakpoint = rb_define_class_under(mDebugger, "Breakpoint", rb_cObject);
    rb_define_method(cBreakpoint, "enabled=", breakpoint_set_enabled, 1);
    rb_define_method(cBreakpoint, "enabled?", breakpoint_enabled, 0);
    rb_define_method(cBreakpoint, "expr", breakpoint_expr, 0);
    rb_define_method(cBreakpoint, "expr=", breakpoint_set_expr, 1);
    rb_define_method(cBreakpoint, "hit_condition", breakpoint_hit_condition, 0);
    rb_define_method(cBreakpoint, "hit_condition=", breakpoint_set_hit_condition, 1);
    rb_define_method(cBreakpoint, "hit_count", breakpoint_hit_count, 0);
    rb_define_method(cBreakpoint, "hit_value", breakpoint_hit_value, 0);
    rb_define_method(cBreakpoint, "hit_value=", breakpoint_set_hit_value, 1);
    rb_define_method(cBreakpoint, "id", breakpoint_id, 0);
    rb_define_method(cBreakpoint, "pos", breakpoint_pos, 0);
    rb_define_method(cBreakpoint, "pos=", breakpoint_set_pos, 1);
    rb_define_method(cBreakpoint, "source", breakpoint_source, 0);
    rb_define_method(cBreakpoint, "source=", breakpoint_set_source, 1);
    idEval             = rb_intern("eval");
    rdebug_catchpoints = rb_hash_new();

}


