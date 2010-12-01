shared_examples_for "session with javascript support" do
  describe 'all JS specs' do
    before do
      Capybara.default_wait_time = 1
    end

    after do
      Capybara.default_wait_time = 0
    end
    
    describe '#find' do
      it "should allow triggering of custom JS events" do
        pending "cannot figure out how to do this with selenium" if @session.mode == :selenium
        @session.visit('/with_js')
        @session.find(:css, '#with_focus_event').trigger(:focus)
        @session.should have_css('#focus_event_triggered')
      end
    end

    describe '#body' do
      it "should return the current state of the page" do
        @session.visit('/with_js')
        @session.body.should include('I changed it')
        @session.body.should_not include('This is text')
      end
    end

    describe '#source' do
      it "should return the original, unmodified source of the page" do
        pending "cannot figure out how to do this with selenium" if @session.mode == :selenium
        @session.visit('/with_js')
        @session.source.should include('This is text')
        @session.source.should_not include('I changed it')
      end
    end

    describe "#evaluate_script" do
      it "should evaluate the given script and return whatever it produces" do
        @session.visit('/with_js')
        @session.evaluate_script("1+3").should == 4
      end
    end

    describe "#execute_script" do
      it "should execute the given script and return nothing" do
        @session.visit('/with_js')
        @session.execute_script("$('#change').text('Funky Doodle')").should be_nil
        @session.should have_css('#change', :text => 'Funky Doodle')
      end
    end

    describe '#locate' do
      it "should wait for asynchronous load" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.locate("//a[contains(.,'Has been clicked')]")[:href].should == '#'
      end
    end

    describe '#wait_until' do
      before do
        @default_timeout = Capybara.default_wait_time
      end

      after do
        Capybara.default_wait_time = @default_wait_time
      end

      it "should wait for block to return true" do
        @session.visit('/with_js')
        @session.select('My Waiting Option', :from => 'waiter')
        @session.evaluate_script('activeRequests == 1').should be_true
        @session.wait_until do
          @session.evaluate_script('activeRequests == 0')
        end
        @session.evaluate_script('activeRequests == 0').should be_true
      end

      it "should raise Capybara::TimeoutError if block doesn't return true within timeout" do
        @session.visit('/with_html')
        Proc.new do
          @session.wait_until(0.1) do
            @session.find('//div[@id="nosuchthing"]')
          end
        end.should raise_error(::Capybara::TimeoutError)
      end

      it "should accept custom timeout in seconds" do
        start = Time.now
        Capybara.default_wait_time = 5
        begin
          @session.wait_until(0.1) { false }
        rescue Capybara::TimeoutError; end
        (Time.now - start).should be_close(0.1, 0.1)
      end

      it "should default to Capybara.default_wait_time before timeout" do
        @session.driver # init the driver to exclude init timing from test
        start = Time.now
        Capybara.default_wait_time = 0.2
        begin
          @session.wait_until { false }
        rescue Capybara::TimeoutError; end
        if @session.driver.has_shortcircuit_timeout?
          (Time.now - start).should be_close(0, 0.1)
        else
          (Time.now - start).should be_close(0.2, 0.1)
        end
      end
    end

    describe '#click' do
      it "should wait for asynchronous load" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.click('Has been clicked')
      end
    end

    describe '#click_link' do
      it "should wait for asynchronous load" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.click_link('Has been clicked')
      end
    end

    describe '#click_button' do
      it "should wait for asynchronous load" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.click_button('New Here')
      end
    end

    describe '#fill_in' do
      it "should wait for asynchronous load" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.fill_in('new_field', :with => 'Testing...')
      end
    end

    describe '#check' do
      it "should trigger associated events" do
        @session.visit('/with_js')
        @session.check('checkbox_with_event')
        @session.should have_css('#checkbox_event_triggered');
      end
    end

    describe '#has_xpath?' do
      it "should wait for content to appear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_xpath("//input[@type='submit' and @value='New Here']")
      end
    end

    describe '#has_no_xpath?' do
      it "should wait for content to disappear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_no_xpath("//p[@id='change']")
      end
    end

    describe '#has_css?' do
      it "should wait for content to appear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_css("input[type='submit'][value='New Here']")
      end
    end

    describe '#has_no_xpath?' do
      it "should wait for content to disappear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_no_css("p#change")
      end
    end

    describe '#has_content?' do
      it "should wait for content to appear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_content("Has been clicked")
      end
    end

    describe '#has_no_content?' do
      it "should wait for content to disappear" do
        @session.visit('/with_js')
        @session.click_link('Click me')
        @session.should have_no_content("I changed it")
      end
    end

  end
end

shared_examples_for "session without javascript support" do
  describe "#evaluate_script" do
    before{ @session.visit('/with_simple_html') }
    it "should raise an error" do
      running {
        @session.evaluate_script('3 + 3')
      }.should raise_error(Capybara::NotSupportedByDriverError)
    end
  end
end
