#!/usr/bin/env ruby

require 'builder/xmlmarkup'
require 'benchmark'

text = "This is a test of the new xml markup. Iñtërnâtiônàlizætiøn\n" * 10000

include Benchmark          # we need the CAPTION and FMTSTR constants
include Builder
n = 50
Benchmark.benchmark do |bm|
  tf = bm.report("base")   {
    n.times do
      x = XmlMarkup.new
      x.text(text)
      x.target!
    end
  }
  def XmlMarkup._escape(text)
    text.to_xs
  end
  tf = bm.report("to_xs")   {
    n.times do
      x = XmlMarkup.new
      x.text(text)
      x.target!
    end
  }
end

