require "mkmf"

if RUBY_VERSION >= "1.9"
  STDERR.print("Can't handle 1.9.x yet\n")
  exit(1)
elsif RUBY_VERSION >= "1.8"
  if RUBY_RELEASE_DATE < "2005-03-22"
    STDERR.print("Ruby version is too old\n")
    exit(1)
  end
else
  STDERR.print("Ruby version is too old\n")
  exit(1)
end

create_makefile("trace_nums")
