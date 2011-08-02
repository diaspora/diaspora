
module Rcov; module Test; module Temporary; class Sample03
  def f1                # MUST NOT CHANGE the position or the tests will break
    10.times { f2 }
  end

  def f2; 1 end

  def f3
    10.times{ f1 }
    100.times{ f2 }
  end                   
  
  def self.g1
    10.times{ g2 }
  end

  def self.g2; 1 end
  # safe from here ...
end end end end
