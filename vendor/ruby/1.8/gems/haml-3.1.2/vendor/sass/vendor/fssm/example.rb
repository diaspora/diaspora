$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'fssm'

FSSM.monitor('.', '**/*') do
  update {|b, r| puts "Update in #{b} to #{r}"}
  delete {|b, r| puts "Delete in #{b} to #{r}"}
  create {|b, r| puts "Create in #{b} to #{r}"}
end
