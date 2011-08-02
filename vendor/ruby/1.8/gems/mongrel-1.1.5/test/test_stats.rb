# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

require 'test/testhelp'

class StatsTest < Test::Unit::TestCase

  def test_sampling_speed
    out = StringIO.new

    s = Mongrel::Stats.new("test")
    t = Mongrel::Stats.new("time")

    100.times { s.sample(rand(20)); t.tick }

    s.dump("FIRST", out)
    t.dump("FIRST", out)
    
    old_mean = s.mean
    old_sd = s.sd

    s.reset
    t.reset
    100.times { s.sample(rand(30)); t.tick }
    
    s.dump("SECOND", out)
    t.dump("SECOND", out)
    assert_not_equal old_mean, s.mean
    assert_not_equal old_mean, s.sd    
  end

end
