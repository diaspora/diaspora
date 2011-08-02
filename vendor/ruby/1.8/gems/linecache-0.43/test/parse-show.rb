#!/usr/bin/env ruby

require 'pp'
begin require 'rubygems' rescue LoadError end
require 'parse_tree'

ARGV.push "-" if ARGV.empty?

parse_tree = ParseTree.new(true)

ARGV.each do |file|
  ruby = file == "-" ? $stdin.read : File.read(file)
  pp parse_tree.parse_tree_for_string(ruby, file).first
end
