#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessagesHelper do
  it "should not allow basic XSS/HTML" do
    make_links("<script>alert('XSS is evil')</script>").should == "&lt;script&gt;alert('XSS is evil')&lt;/script&gt;"
  end

  it "should recognize basic http links (1/3)" do
    proto="http"
    url="bugs.joindiaspora.com/issues/332"
    make_links(proto+"://"+url).should == "<a target=\"_blank\" href=\""+proto+"://"+url+"\">"+url+"</a>"
  end

  it "should recognize basic http links (2/3)" do
    proto="http"
    url="www.youtube.com/watch?v=b15yaPYNDRU"
    make_links(proto+"://"+url).should == "<a target=\"_blank\" href=\""+proto+"://"+url+"\">"+url+"</a>"
  end

  it "should recognize basic http links (3/3)" do
    proto="http"
    url="127.0.0.1:3000/users/sign_in"
    make_links(proto+"://"+url).should == "<a target=\"_blank\" href=\""+proto+"://"+url+"\">"+url+"</a>"
  end
  
  it "should recognize basic ftp links" do
    proto="ftp"
    url="ftp.uni-kl.de/CCC/26C3/mp4/26c3-3540-en-a_hackers_utopia.mp4"
    # I did not watch that one, but the title sounds nice :P
    make_links(proto+"://"+url).should == "<a target=\"_blank\" href=\""+proto+"://"+url+"\">"+url+"</a>"
  end

  it "should recognize www links" do
    url="www.joindiaspora.com"
    make_links(url).should == "<a target=\"_blank\" href=\"http://"+url+"\">"+url+"</a>"
  end

  
end
