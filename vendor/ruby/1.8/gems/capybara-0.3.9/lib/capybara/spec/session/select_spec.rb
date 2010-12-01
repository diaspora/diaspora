shared_examples_for "select" do
  describe "#select" do
    before do
      @session.visit('/form')
    end
    
    it "should return value of the first option" do
      @session.find_field('Title').value.should == 'Mrs'
    end

    it "should return value of the selected option" do
      @session.select("Miss", :from => 'Title')
      @session.find_field('Title').value.should == 'Miss'
    end

    it "should select an option from a select box by id" do
      @session.select("Finish", :from => 'form_locale')
      @session.click_button('awesome')
      extract_results(@session)['locale'].should == 'fi'
    end

    it "should select an option from a select box by label" do
      @session.select("Finish", :from => 'Locale')
      @session.click_button('awesome')
      extract_results(@session)['locale'].should == 'fi'
    end

    it "should favour exact matches to option labels" do
      @session.select("Mr", :from => 'Title')
      @session.click_button('awesome')
      extract_results(@session)['title'].should == 'Mr'
    end

    it "should escape quotes" do
      @session.select("John's made-up language", :from => 'Locale')
      @session.click_button('awesome')
      extract_results(@session)['locale'].should == 'jo'
    end

    it "should obey from" do
      @session.select("Miss", :from => "Other title")
      @session.click_button('awesome')
      results = extract_results(@session)
      results['other_title'].should == "Miss"
      results['title'].should_not == "Miss"
    end

    it "show match labels with preceding or trailing whitespace" do
      @session.select("Lojban", :from => 'Locale')
      @session.click_button('awesome')
      extract_results(@session)['locale'].should == 'jbo'
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running { @session.select('foo', :from => 'does not exist') }.should raise_error(Capybara::ElementNotFound)
      end
    end

    context "with an option that doesn't exist" do
      it "should raise an error" do
        running { @session.select('Does not Exist', :from => 'form_locale') }.should raise_error(Capybara::OptionNotFound)
      end
    end

    context "with multiple select" do
      it "should return an empty value" do
        @session.find_field('Language').value.should == []
      end

      it "should return value of the selected options" do
        @session.select("Ruby",       :from => 'Language')
        @session.select("Javascript", :from => 'Language')
        @session.find_field('Language').value.should include('Ruby', 'Javascript')
      end

      it "should select one option" do
        @session.select("Ruby", :from => 'Language')
        @session.click_button('awesome')
        extract_results(@session)['languages'].should == ['Ruby']
      end

      it "should select multiple options" do
        @session.select("Ruby",       :from => 'Language')
        @session.select("Javascript", :from => 'Language')
        @session.click_button('awesome')
        extract_results(@session)['languages'].should include('Ruby', 'Javascript')
      end
    end
  end
end
