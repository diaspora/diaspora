                                                                            #o
module Rcov; module Test; module Temporary; class Sample03                  #o
  def f1                # MUST NOT CHANGE the position or the tests will break # << [[sample_03_rb.rb:10 in Rcov::Test::Temporary::Sample03#f3]], [[sample_04_rb.rb:6 in #]], 
    10.times { f2 }                                                         # >> [[Rcov::Test::Temporary::Sample03#f2 at sample_03_rb.rb:7]], 
  end                                                                       #o
                                                                            #o
  def f2; 1 end                                                             # << [[sample_03_rb.rb:4 in Rcov::Test::Temporary::Sample03#f1]], [[sample_03_rb.rb:11 in Rcov::Test::Temporary::Sample03#f3]], [[sample_04_rb.rb:7 in #]], 
                                                                            #o
  def f3                                                                    # << [[sample_04_rb.rb:8 in #]], 
    10.times{ f1 }                                                          # >> [[Rcov::Test::Temporary::Sample03#f1 at sample_03_rb.rb:3]], 
    100.times{ f2 }                                                         # >> [[Rcov::Test::Temporary::Sample03#f2 at sample_03_rb.rb:7]], 
  end                                                                       #o
                                                                            #o
  def self.g1                                                               #o
    10.times{ g2 }
  end
                                                                            #o
  def self.g2; 1 end                                                        # << [[sample_04_rb.rb:10 in #]], 
  # safe from here ...
end end end end
# Total lines    : 20
# Lines of code  : 14
# Total coverage : 80.0%
# Code coverage  : 78.6%

# Local Variables:
# mode: rcov-xref
# End:
