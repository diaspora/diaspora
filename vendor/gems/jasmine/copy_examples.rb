#!/usr/bin/env ruby

require "fileutils"

# copy jasmine's example tree into our generator templates dir
FileUtils.rm_r('generators/jasmine/templates/jasmine-example', :force => true)
FileUtils.cp_r('jasmine/example', 'generators/jasmine/templates/jasmine-example', :preserve => true)
