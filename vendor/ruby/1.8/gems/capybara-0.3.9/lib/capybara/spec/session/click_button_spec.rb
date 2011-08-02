shared_examples_for "click_button" do
  describe '#click_button' do
    before do
      @session.visit('/form')
    end

    context "with multiple values with the same name" do
      it "should use the latest given value" do
        @session.check('Terms of Use')
        @session.click_button('awesome')
        extract_results(@session)['terms_of_use'].should == '1'
      end
    end

    context "with value given on a submit button" do
      context "on a form with HTML5 fields" do
        before do
          @session.click_button('html5_submit')
          @results = extract_results(@session)
        end

        it "should serialise and submit search fields" do
          @results['html5_search'].should == 'what are you looking for'
        end

        it "should serialise and submit email fields" do
          @results['html5_email'].should == 'person@email.com'
        end

        it "should serialise and submit url fields" do
          @results['html5_url'].should == 'http://www.example.com'
        end

        it "should serialise and submit tel fields" do
          @results['html5_tel'].should == '911'
        end

        it "should serialise and submit color fields" do
          @results['html5_color'].should == '#FFF'
        end
      end

      context "on an HTML4 form" do
        before do
          @session.click_button('awesome')
          @results = extract_results(@session)
        end

        it "should serialize and submit text fields" do
          @results['first_name'].should == 'John'
        end

        it "should escape fields when submitting" do
          @results['phone'].should == '+1 555 7021'
        end

        it "should serialize and submit password fields" do
          @results['password'].should == 'seeekrit'
        end

        it "should serialize and submit hidden fields" do
          @results['token'].should == '12345'
        end

        it "should not serialize fields from other forms" do
          @results['middle_name'].should be_nil
        end

        it "should submit the button that was clicked, but not other buttons" do
          @results['awesome'].should == 'awesome'
          @results['crappy'].should be_nil
        end

        it "should serialize radio buttons" do
          @results['gender'].should == 'female'
        end

        it "should serialize check boxes" do
          @results['pets'].should include('dog', 'hamster')
          @results['pets'].should_not include('cat')
        end

        it "should serialize text areas" do
          @results['description'].should == 'Descriptive text goes here'
        end

        it "should serialize select tag with values" do
          @results['locale'].should == 'en'
        end

        it "should serialize select tag without values" do
          @results['region'].should == 'Norway'
        end

        it "should serialize first option for select tag with no selection" do
          @results['city'].should == 'London'
        end

        it "should not serialize a select tag without options" do
          @results['tendency'].should be_nil
        end
      end
    end

    context "with id given on a submit button" do
      it "should submit the associated form" do
        @session.click_button('awe123')
        extract_results(@session)['first_name'].should == 'John'
      end

      it "should work with partial matches" do
        @session.click_button('Go')
        @session.body.should include('You landed')
      end
    end
    
    context "with alt given on an image button" do
      it "should submit the associated form" do
        @session.click_button('oh hai thar')
        extract_results(@session)['first_name'].should == 'John'
      end

      it "should work with partial matches" do
        @session.click_button('hai')
        extract_results(@session)['first_name'].should == 'John'
      end
    end

    context "with value given on an image button" do
      it "should submit the associated form" do
        @session.click_button('okay')
        extract_results(@session)['first_name'].should == 'John'
      end

      it "should work with partial matches" do
        @session.click_button('kay')
        extract_results(@session)['first_name'].should == 'John'
      end
    end

    context "with id given on an image button" do
      it "should submit the associated form" do
        @session.click_button('okay556')
        extract_results(@session)['first_name'].should == 'John'
      end
    end

    context "with text given on a button defined by <button> tag" do
      it "should submit the associated form" do
        @session.click_button('Click me')
        extract_results(@session)['first_name'].should == 'John'
      end

      it "should work with partial matches" do
        @session.click_button('Click')
        extract_results(@session)['first_name'].should == 'John'
      end

      it "should prefer exact matches over partial matches" do
        @session.click_button('Just an input')
        extract_results(@session)['button'].should == 'button_second'
      end
    end

   context "with id given on a button defined by <button> tag" do
      it "should submit the associated form" do
        @session.click_button('click_me_123')
        extract_results(@session)['first_name'].should == 'John'
      end

      it "should serialize and send GET forms" do
        @session.visit('/form')
        @session.click_button('med')
        @results = extract_results(@session)
        @results['middle_name'].should == 'Darren'
        @results['foo'].should be_nil
      end
    end

   context "with value given on a button defined by <button> tag" do
      it "should submit the associated form" do
        @session.click_button('click_me')
        extract_results(@session)['first_name'].should == 'John'
      end

      it "should work with partial matches" do
        @session.click_button('ck_me')
        extract_results(@session)['first_name'].should == 'John'
      end

      it "should prefer exact matches over partial matches" do
        @session.click_button('Just a button')
        extract_results(@session)['button'].should == 'Just a button'
      end
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running do
          @session.click_button('does not exist')
        end.should raise_error(Capybara::ElementNotFound)
      end
    end

    it "should serialize and send valueless buttons that were clicked" do
      @session.click_button('No Value!')
      @results = extract_results(@session)
      @results['no_value'].should_not be_nil
    end
    
    it "should not send image buttons that were not clicked" do
      @session.click_button('Click me!')
      @results = extract_results(@session)
      @results['okay'].should be_nil
    end

    it "should serialize and send GET forms" do
      @session.visit('/form')
      @session.click_button('med')
      @results = extract_results(@session)
      @results['middle_name'].should == 'Darren'
      @results['foo'].should be_nil
    end

    it "should follow redirects" do
      @session.click_button('Go FAR')
      @session.current_url.should match(%r{/landed$})
      @session.body.should include('You landed')
    end

    it "should post pack to the same URL when no action given" do
      @session.visit('/postback')
      @session.click_button('With no action')
      @session.body.should include('Postback')
    end

    it "should post pack to the same URL when blank action given" do
      @session.visit('/postback')
      @session.click_button('With blank action')
      @session.body.should include('Postback')
    end
  end
end
