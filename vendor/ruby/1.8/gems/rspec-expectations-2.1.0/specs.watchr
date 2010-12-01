# Run me with:
#
#   $ watchr specs.watchr

# --------------------------------------------------
# Convenience Methods
# --------------------------------------------------
def all_test_files
  Dir['spec/**/*_spec.rb']
end

def run_test_matching(thing_to_match)
  matches = all_test_files.grep(/#{thing_to_match}/i)
  if matches.empty?
    puts "Sorry, thanks for playing, but there were no matches for #{thing_to_match}"  
  else
    run matches.join(' ')
  end
end

def run(files_to_run)
  puts("Running: #{files_to_run}")
  system("clear;rspec -cfs #{files_to_run}")
  no_int_for_you
end

def run_all_tests
  run(all_test_files.join(' '))
end

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch('^spec/(.*)_spec\.rb'  )   { |m| run_test_matching(m[1]) }
watch('^lib/(.*)\.rb'               )   { |m| run_test_matching(m[1]) }
watch('^spec/spec_helper\.rb')   { run_all_tests }
# --------------------------------------------------
# Signal Handling
# --------------------------------------------------

def no_int_for_you
  @sent_an_int = nil
end

Signal.trap 'INT' do
  if @sent_an_int then      
    puts "   A second INT?  Ok, I get the message.  Shutting down now."
    exit
  else
    puts "   Did you just send me an INT? Ugh.  I'll quit for real if you do it again."
    @sent_an_int = true
    Kernel.sleep 1.5
    run_all_tests
  end
end

# vim:ft=ruby
