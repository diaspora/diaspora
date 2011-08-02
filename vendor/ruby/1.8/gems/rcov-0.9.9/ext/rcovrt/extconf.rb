require 'mkmf'

dir_config("gcov")
if ENV["USE_GCOV"] and Config::CONFIG['CC'] =~ /gcc/ and 
  have_library("gcov", "__gcov_open")

  $CFLAGS << " -fprofile-arcs -ftest-coverage"
  if RUBY_VERSION =~ /1.9/
    $CFLAGS << ' -DRUBY_19_COMPATIBILITY'
    create_makefile("rcovrt", "1.9/")
  else
    create_makefile("rcovrt", "1.8/")
  end
else
  if RUBY_VERSION =~ /1.9/
    $CFLAGS << ' -DRUBY_19_COMPATIBILITY'
    create_makefile("rcovrt", "1.9/")
  else
    create_makefile("rcovrt", "1.8/")
  end
end
