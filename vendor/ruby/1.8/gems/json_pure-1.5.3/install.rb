#!/usr/bin/env ruby

require 'rbconfig'
require 'fileutils'
include FileUtils::Verbose

include Config

bindir = CONFIG["bindir"]
cd 'bin' do
  filename = 'edit_json.rb'
  #install(filename, bindir)
end
sitelibdir = CONFIG["sitelibdir"]
cd 'lib' do
  install('json.rb', sitelibdir)
  mkdir_p File.join(sitelibdir, 'json')
  for file in Dir['json/**/*.{rb,xpm}']
    d = File.join(sitelibdir, file)
    mkdir_p File.dirname(d)
    install(file, d)
  end
  install(File.join('json', 'editor.rb'), File.join(sitelibdir,'json'))
  install(File.join('json', 'json.xpm'), File.join(sitelibdir,'json'))
end
warn " *** Installed PURE ruby library."
