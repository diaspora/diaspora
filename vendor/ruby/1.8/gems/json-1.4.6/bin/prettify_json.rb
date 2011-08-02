#!/usr/bin/env ruby

require 'json'
require 'fileutils'
include FileUtils

# Parses the argument array _args_, according to the pattern _s_, to
# retrieve the single character command line options from it. If _s_ is
# 'xy:' an option '-x' without an option argument is searched, and an
# option '-y foo' with an option argument ('foo').
#
# An option hash is returned with all found options set to true or the
# found option argument.
def go(s, args = ARGV)
  b, v = s.scan(/(.)(:?)/).inject([{},{}]) { |t,(o,a)|
    t[a.empty? ? 0 : 1][o] = a.empty? ? false : nil
    t
  }
  while a = args.shift
    a !~ /\A-(.+)/ and args.unshift a and break
    p = $1
    until p == ''
      o = p.slice!(0, 1)
      if v.key?(o)
        v[o] = if p == '' then args.shift or break 1 else p end
        break
      elsif b.key?(o)
        b[o] = true
      else
        args.unshift a
        break 1
      end
    end and break
  end
  b.merge(v)
end

opts = go 'slhi:', args = ARGV.dup
if opts['h'] || opts['l'] && opts['s']
  puts <<EOT
Usage: #{File.basename($0)} [OPTION] [FILE]

If FILE is skipped, this scripts waits for input from STDIN. Otherwise
FILE is opened, read, and used as input for the prettifier.

OPTION can be
  -s     to output the shortest possible JSON (precludes -l)
  -l     to output a longer, better formatted JSON (precludes -s)
  -i EXT prettifies FILE in place, saving a backup to FILE.EXT
  -h     this help
EOT
  exit 0
end

filename = nil
json = JSON[
  if args.empty?
    STDIN.read
  else
    File.read filename = args.first
  end
]

output = if opts['s']
  JSON.fast_generate json
else # default is -l
  JSON.pretty_generate json
end

if opts['i'] && filename
  cp filename, "#{filename}.#{opts['i']}"
  File.open(filename, 'w') { |f| f.puts output }
else
  puts output
end
