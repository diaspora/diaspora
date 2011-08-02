module CheckSpec
  shared_examples_for "check" do
  
    describe "#check" do
      before do
        @session.visit('/form')
      end
      
      describe "'checked' attribute" do
        it "should be true if checked" do
          @session.check("Terms of Use")
          @session.find(:xpath, "//input[@id='form_terms_of_use']")['checked'].should be_true
        end
        
        it "should be false if unchecked" do
          @session.find(:xpath, "//input[@id='form_terms_of_use']")['checked'].should be_false
        end
      end

      describe "checking" do
        it "should not change an already checked checkbox" do
          @session.find(:xpath, "//input[@id='form_pets_dog']")['checked'].should be_true
          @session.check('form_pets_dog')
          @session.find(:xpath, "//input[@id='form_pets_dog']")['checked'].should be_true
        end

        it "should check an unchecked checkbox" do
          @session.find(:xpath, "//input[@id='form_pets_cat']")['checked'].should be_false
          @session.check('form_pets_cat')
          @session.find(:xpath, "//input[@id='form_pets_cat']")['checked'].should be_true
        end
      end

      describe "unchecking" do
        it "should not change an already unchecked checkbox" do
          @session.find(:xpath, "//input[@id='form_pets_cat']")['checked'].should be_false
          @session.uncheck('form_pets_cat')
          @session.find(:xpath, "//input[@id='form_pets_cat']")['checked'].should be_false
        end

        it "should uncheck a checked checkbox" do
          @session.find(:xpath, "//input[@id='form_pets_dog']")['checked'].should be_true
          @session.uncheck('form_pets_dog')
          @session.find(:xpath, "//input[@id='form_pets_dog']")['checked'].should be_false
        end
      end

      it "should check a checkbox by id" do
        @session.check("form_pets_cat")
        @session.click_button('awesome')
        extract_results(@session)['pets'].should include('dog', 'cat', 'hamster')
      end

      it "should check a checkbox by label" do
        @session.check("Cat")
        @session.click_button('awesome')
        extract_results(@session)['pets'].should include('dog', 'cat', 'hamster')
      end

      context "with a locator that doesn't exist" do
        it "should raise an error" do
          running { @session.check('does not exist') }.should raise_error(Capybara::ElementNotFound)
        end
      end
    end
  end
end  
