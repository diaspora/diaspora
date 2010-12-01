require 'mkmf'

dir_config("http11")
have_library("c", "main")

create_makefile("http11")
