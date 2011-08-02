#!/usr/bin/env ruby
require 'json/editor'

filename, encoding = ARGV
JSON::Editor.start(encoding) do |window|
  if filename
    window.file_open(filename)
  end
end
