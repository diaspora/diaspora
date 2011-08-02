shared_examples_for "has_xpath" do  
  describe '#has_xpath?' do
    before do
      @session.visit('/with_html')
    end

    it "should be true if the given selector is on the page" do
      @session.should have_xpath("//p")
      @session.should have_xpath("//p//a[@id='foo']")
      @session.should have_xpath("//p[contains(.,'est')]")
    end

    it "should be false if the given selector is not on the page" do
      @session.should_not have_xpath("//abbr")
      @session.should_not have_xpath("//p//a[@id='doesnotexist']")
      @session.should_not have_xpath("//p[contains(.,'thisstringisnotonpage')]")
    end

    it "should use xpath even if default selector is CSS" do
      Capybara.default_selector = :css
      @session.should_not have_xpath("//p//a[@id='doesnotexist']")
    end

    it "should respect scopes" do
      @session.within "//p[@id='first']" do
        @session.should have_xpath("//a[@id='foo']")
        @session.should_not have_xpath("//a[@id='red']")
      end
    end

    context "with count" do
      it "should be true if the content is on the page the given number of times" do
        @session.should have_xpath("//p", :count => 3)
        @session.should have_xpath("//p//a[@id='foo']", :count => 1)
        @session.should have_xpath("//p[contains(.,'est')]", :count => 1)
      end

      it "should be false if the content is on the page the given number of times" do
        @session.should_not have_xpath("//p", :count => 6)
        @session.should_not have_xpath("//p//a[@id='foo']", :count => 2)
        @session.should_not have_xpath("//p[contains(.,'est')]", :count => 5)
      end

      it "should be false if the content isn't on the page at all" do
        @session.should_not have_xpath("//abbr", :count => 2)
        @session.should_not have_xpath("//p//a[@id='doesnotexist']", :count => 1)
      end
    end

    context "with text" do
      it "should discard all matches where the given string is not contained" do
        @session.should have_xpath("//p//a", :text => "Redirect", :count => 1)
        @session.should_not have_xpath("//p", :text => "Doesnotexist")
      end

      it "should discard all matches where the given regexp is not matched" do
        @session.should have_xpath("//p//a", :text => /re[dab]i/i, :count => 1)
        @session.should_not have_xpath("//p//a", :text => /Red$/)
      end
    end
  end

  describe '#has_no_xpath?' do
    before do
      @session.visit('/with_html')
    end

    it "should be false if the given selector is on the page" do
      @session.should_not have_no_xpath("//p")
      @session.should_not have_no_xpath("//p//a[@id='foo']")
      @session.should_not have_no_xpath("//p[contains(.,'est')]")
    end

    it "should be true if the given selector is not on the page" do
      @session.should have_no_xpath("//abbr")
      @session.should have_no_xpath("//p//a[@id='doesnotexist']")
      @session.should have_no_xpath("//p[contains(.,'thisstringisnotonpage')]")
    end

    it "should use xpath even if default selector is CSS" do
      Capybara.default_selector = :css
      @session.should have_no_xpath("//p//a[@id='doesnotexist']")
    end

    it "should respect scopes" do
      @session.within "//p[@id='first']" do
        @session.should_not have_no_xpath("//a[@id='foo']")
        @session.should have_no_xpath("//a[@id='red']")
      end
    end

    context "with count" do
      it "should be false if the content is on the page the given number of times" do
        @session.should_not have_no_xpath("//p", :count => 3)
        @session.should_not have_no_xpath("//p//a[@id='foo']", :count => 1)
        @session.should_not have_no_xpath("//p[contains(.,'est')]", :count => 1)
      end

      it "should be true if the content is on the page the wrong number of times" do
        @session.should have_no_xpath("//p", :count => 6)
        @session.should have_no_xpath("//p//a[@id='foo']", :count => 2)
        @session.should have_no_xpath("//p[contains(.,'est')]", :count => 5)
      end

      it "should be true if the content isn't on the page at all" do
        @session.should have_no_xpath("//abbr", :count => 2)
        @session.should have_no_xpath("//p//a[@id='doesnotexist']", :count => 1)
      end
    end

    context "with text" do
      it "should discard all matches where the given string is contained" do
        @session.should_not have_no_xpath("//p//a", :text => "Redirect", :count => 1)
        @session.should have_no_xpath("//p", :text => "Doesnotexist")
      end

      it "should discard all matches where the given regexp is matched" do
        @session.should_not have_no_xpath("//p//a", :text => /re[dab]i/i, :count => 1)
        @session.should have_no_xpath("//p//a", :text => /Red$/)
      end
    end
  end
end
