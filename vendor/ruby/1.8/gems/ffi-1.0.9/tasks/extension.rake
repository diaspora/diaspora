spec = Gem::Specification.new do |s|
  s.name = PROJ.name
  s.version = PROJ.version
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.summary = PROJ.summary
  s.description = PROJ.description
  s.authors = Array(PROJ.authors)
  s.email = PROJ.email
  s.homepage = Array(PROJ.url).first
  s.rubyforge_project = PROJ.rubyforge.name
  s.extensions = %w(ext/ffi_c/extconf.rb gen/Rakefile)
  s.require_path = 'lib'
  s.files = PROJ.gem.files
  s.add_dependency *PROJ.gem.dependencies.flatten unless PROJ.gem.dependencies.empty?
  PROJ.gem.extras.each do |msg, val|
    case val
    when Proc
      val.call(s.send(msg))
    else
      s.send "#{msg}=", val
    end
  end
end

Rake::ExtensionTask.new('ffi_c', spec) do |ext|
  ext.name = 'ffi_c'                                        # indicate the name of the extension.
  # ext.lib_dir = BUILD_DIR                                 # put binaries into this folder.
  ext.tmp_dir = BUILD_DIR                                   # temporary folder used during compilation.
  ext.cross_compile = true                                  # enable cross compilation (requires cross compile toolchain)
  ext.cross_platform = ['i386-mingw32']     # forces the Windows platform instead of the default one
end if USE_RAKE_COMPILER
