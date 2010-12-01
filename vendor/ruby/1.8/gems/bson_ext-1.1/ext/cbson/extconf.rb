require 'mkmf'

have_func("asprintf")

have_header("ruby/st.h") || have_header("st.h")
have_header("ruby/regex.h") || have_header("regex.h")
have_header("ruby/encoding.h")

dir_config('cbson')
create_makefile('bson_ext/cbson')
