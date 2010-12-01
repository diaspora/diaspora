require 'mkmf'
require 'rbconfig'

unless $CFLAGS.gsub!(/ -O[\dsz]?/, ' -O3')
  $CFLAGS << ' -O3'
end
if CONFIG['CC'] =~ /gcc/
  $CFLAGS << ' -Wall'
  #unless $CFLAGS.gsub!(/ -O[\dsz]?/, ' -O0 -ggdb')
  #  $CFLAGS << ' -O0 -ggdb'
  #end
end

have_header("re.h")
create_makefile 'json/ext/parser'
