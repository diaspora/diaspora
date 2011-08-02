shared_examples_for "click_link" do
  describe '#click_link' do
    before do
      @session.visit('/with_html')
    end

    context "with id given" do
      it "should take user to the linked page" do
        @session.click_link('foo')
        @session.body.should include('Another World')
      end
    end

    context "with text given" do
      it "should take user to the linked page" do
        @session.click_link('labore')
        @session.body.should include('Bar')
      end
      
      it "should accept partial matches" do
        @session.click_link('abo')
        @session.body.should include('Bar')
      end

      it "should prefer exact matches over partial matches" do
        @session.click_link('A link')
        @session.body.should include('Bar')
      end
    end

    context "with title given" do
      it "should take user to the linked page" do
        @session.click_link('awesome title')
        @session.body.should include('Bar')
      end

      it "should accept partial matches" do
        @session.click_link('some tit')
        @session.body.should include('Bar')
      end
      
      it "should prefer exact matches over partial matches" do
        @session.click_link('a fine link')
        @session.body.should include('Bar')
      end
    end

    context "with alternative text given to a contained image" do
      it "should take user to the linked page" do
        @session.click_link('awesome image')
        @session.body.should include('Bar')
      end

      it "should take user to the linked page" do
        @session.click_link('some imag')
        @session.body.should include('Bar')
      end

      it "should prefer exact matches over partial matches" do
        @session.click_link('fine image')
        @session.body.should include('Bar')
      end
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running do
          @session.click_link('does not exist')
        end.should raise_error(Capybara::ElementNotFound)
      end
    end

    it "should follow redirects" do
      @session.click_link('Redirect')
      @session.body.should include('You landed')
    end
    
    it "should follow redirects" do
      @session.click_link('BackToMyself')
      @session.body.should include('This is a test')
    end
    
    it "should do nothing on anchor links" do
      @session.fill_in("test_field", :with => 'blah')
      @session.click_link('Anchor')
      @session.find_field("test_field").value.should == 'blah'
      @session.click_link('Blank Anchor')
      @session.find_field("test_field").value.should == 'blah'
    end
    
    it "should do nothing on URL+anchor links for the same page" do
      @session.fill_in("test_field", :with => 'blah')
      @session.click_link('Anchor on same page')
      @session.find_field("test_field").value.should == 'blah'
    end
    
    it "should follow link on URL+anchor links for a different page" do
      @session.click_link('Anchor on different page')
      @session.body.should include('Bar')
    end
    
    it "raise an error with links with no href" do
      running do
        @session.click_link('No Href')
      end.should raise_error(Capybara::ElementNotFound)
    end
  end
end
