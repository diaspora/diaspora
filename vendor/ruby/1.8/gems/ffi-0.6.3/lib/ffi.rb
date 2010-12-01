begin
  if RUBY_VERSION =~ /1.8/
    require '1.8/ffi_c'
  elsif RUBY_VERSION =~ /1.9/
    require '1.9/ffi_c'
  end
rescue Exception
  require 'ffi_c'
end

require 'ffi/ffi'