# encoding: utf-8
require 'cucumber/formatter/unicode'
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end

$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'basket'
require 'belly'
