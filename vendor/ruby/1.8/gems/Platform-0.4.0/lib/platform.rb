#
# platform.rb: naive platform detection for Ruby
# author: Matt Mower <self@mattmower.com>
#

# == Platform
#
# Platform is a simple module which parses the Ruby constant
# RUBY_PLATFORM and works out the OS, it's implementation,
# and the architecture it's running on.
#
# The motivation for writing this was coming across a case where
#
# +if RUBY_PLATFORM =~ /win/+
#
# didn't behave as expected (i.e. on powerpc-darwin-8.1.0)
#
# It is hoped that providing a library for parsing the platform
# means that we can cover all the cases and have something which
# works reliably 99% of the time.
#
# Please report any anomalies or new combinations to the author(s).
#
# == Use
#
# require "platform"
#
# defines
#
# Platform::OS (:unix,:win32,:vms,:os2)
# Platform::IMPL (:macosx,:linux,:mswin)
# Platform::ARCH (:powerpc,:x86,:alpha)
#
# if an unknown configuration is encountered any (or all) of
# these constant may have the value :unknown.
#
# To display the combination for your setup run
#
# ruby platform.rb
#
module Platform

   # Each platform is defined as
   # [ /regex/, ::OS, ::IMPL ]
   # define them from most to least specific and
   # [ /.*/, :unknown, :unknown ] should always come last
   # whither AIX, SOLARIS, and the other unixen?
   PLATFORMS = [
      [ /darwin/i,   :unix,      :macosx ],
      [ /linux/i,    :unix,      :linux ],
      [ /freebsd/i,  :unix,      :freebsd ],
      [ /netbsd/i,   :unix,      :netbsd ],
      [ /mswin/i,    :win32,     :mswin ], 
      [ /cygwin/i,   :hybrid,    :cygwin ],
      [ /mingw/i,    :win32,     :mingw ],
      [ /bccwin/i,   :win32,     :bccwin ],
      [ /wince/i,    :win32,     :wince ], 
      [ /vms/i,      :vms,       :vms ],
      [ /os2/i,      :os2,       :os2 ],
      [ /solaris/i,  :unix,      :solaris ], 
      [ /irix/i,     :unix,      :irix ], 
      [ /.*/,        :unknown,   :unknown ]
   ]
   (*), OS, IMPL = PLATFORMS.find { |p| RUBY_PLATFORM =~ /#{p[0]}/ }
      
   # What about AMD, Turion, Motorola, etc..?
   ARCHS = [
      [ /i\d86/,     :x86 ],
      [ /ia64/,      :ia64 ],
      [ /powerpc/,   :powerpc ],
      [ /alpha/,     :alpha ],
      [ /sparc/i,    :sparc ], 
      [ /mips/i,     :mips ], 
      [ /.*/,        :unknown ]
   ]   
   (*), ARCH = ARCHS.find { |a| RUBY_PLATFORM =~ /#{a[0]}/}   
   
end

if __FILE__ == $0
   puts "Platform OS=#{Platform::OS}, IMPL=#{Platform::IMPL}, ARCH=#{Platform::ARCH}"
end
