require File.dirname(__FILE__) + '/../spec/gherkin/java_libs'
# To test out the pure Java main program on .NET, execute:
#
#   rake ikvm
#
# Just print dots:
#
#   [mono] pkg/gherkin.exe features
#
# Pretty print all to STDOUT:
#
#   [mono] pkg/gherkin.exe features pretty
#
# To test out the pure C# main program on .NET, execute:
#
#   rake ikvm (you need this to generate all the .dll files needed for the next step)
#
# Then build ikvm/Gherkin.sln. Then:
#
#   [mono] mono ikvm/Gherkin/bin/Debug/Gherkin.exe features/steps_parser.feature
#
namespace :ikvm do
  def mono(args)
    if(`which mono`.strip =~ /mono/)
      sh("mono #{args}")
    else
      raise "[ERROR] You must install Mono and IKVM build gherkin for .NET. See README.rdoc"
    end
  end

  def ikvmc(args)
    begin
      mono("/usr/local/ikvm/bin/ikvmc.exe #{args}")
    rescue => e
      if e.message =~ /Cannot open assembly/
        e.message << "\n\n[ERROR] You must install Mono and IKVM build gherkin for .NET. See README.rdoc"
      end
      raise e
    end
  end

  def references
    JAVA_LIBS.keys.map{|name| "-reference:release/#{name}.dll"}.join(' ')
  end

  task :dependent_dlls do
    mkdir_p 'release' unless File.directory?('release')
    JAVA_LIBS.each do |name, jar|
      ikvmc("-target:library #{jar} -out:release/#{name}.dll")
    end
  end

  desc 'Make a .NET .exe'
  task :exe => ['lib/gherkin.jar', :dependent_dlls] do
    ikvmc("-target:exe lib/gherkin.jar -out:release/gherkin-#{GHERKIN_VERSION}.exe #{references}")
  end

  desc 'Make a .NET .dll'
  task :dll => ['lib/gherkin.jar', :dependent_dlls] do
    mkdir_p 'release' unless File.directory?('release')
    ikvmc("-target:library lib/gherkin.jar -out:release/gherkin-#{GHERKIN_VERSION}.dll  #{references}")
    cp "release/gherkin-#{GHERKIN_VERSION}.dll", 'lib/gherkin.dll'
  end

  desc 'Copy the IKVM .dll files over to the pkg dir'
  task :copy_ikvm_dlls do
    Dir['/usr/local/ikvm/bin/{IKVM.OpenJDK.Core,IKVM.OpenJDK.Text,IKVM.OpenJDK.Security,IKVM.Runtime}.dll'].each do |dll|
      mkdir_p 'release' unless File.directory?('release')
      cp dll, 'release'
      cp dll, 'lib'
    end
  end
end

task :ikvm => ['ikvm:copy_ikvm_dlls', 'ikvm:exe', 'ikvm:dll'] do
  puts "************** Pretty printing some features with .NET. **************"
  mono "release/gherkin-#{GHERKIN_VERSION}.exe features"
  puts "************** DONE Pretty printing some features with .NET. All OK. **************"
end

