# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'term-ansicolor'
  path_name   'term/ansicolor'
  path_module 'Term::ANSIColor'
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "http://flori.github.com/#{name}"
  summary     'Ruby library that colors strings using ANSI escape sequences'
  description ''
  test_dir    'tests'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock'
  readme      'README.rdoc'
  executables << 'cdiff' << 'decolor'

  install_library do
    destdir = "#{ENV['DESTDIR']}"
    libdir = CONFIG["sitelibdir"]
    cd 'lib' do
      for file in Dir['**/*.rb']
        dest = destdir + File.join(libdir, File.dirname(file))
        mkdir_p dest
        install file, dest
      end
    end
  end
end
