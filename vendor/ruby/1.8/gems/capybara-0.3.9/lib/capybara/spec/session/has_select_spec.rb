shared_examples_for "has_select" do  
  describe '#has_select?' do
    before { @session.visit('/form') }

    it "should be true if the field is on the page" do
      @session.should have_select('Locale')
      @session.should have_select('form_region')
      @session.should have_select('Languages')
    end

    it "should be false if the field is not on the page" do
      @session.should_not have_select('Monkey')
    end

    context 'with selected value' do
      it "should be true if a field with the given value is on the page" do
        @session.should have_select('form_locale', :selected => 'English')  
        @session.should have_select('Region', :selected => 'Norway')  
        @session.should have_select('Underwear', :selected => ['Briefs', 'Commando'])
      end

      it "should be false if the given field is not on the page" do
        @session.should_not have_select('Locale', :selected => 'Swedish')  
        @session.should_not have_select('Does not exist', :selected => 'John')  
        @session.should_not have_select('City', :selected => 'Not there')
        @session.should_not have_select('Underwear', :selected => ['Briefs', 'Nonexistant'])
        @session.should_not have_select('Underwear', :selected => ['Briefs', 'Boxers'])
      end
    end

    context 'with options' do
      it "should be true if a field with the given options is on the page" do
        @session.should have_select('form_locale', :options => ['English'])  
        @session.should have_select('Region', :options => ['Norway', 'Sweden'])  
      end

      it "should be false if the given field is not on the page" do
        @session.should_not have_select('Locale', :options => ['Not there'])
        @session.should_not have_select('Does not exist', :options => ['John'])  
        @session.should_not have_select('City', :options => ['London', 'Made up city'])
      end
    end
  end

  describe '#has_no_select?' do
    before { @session.visit('/form') }

    it "should be false if the field is on the page" do
      @session.should_not have_no_select('Locale')
      @session.should_not have_no_select('form_region')
      @session.should_not have_no_select('Languages')
    end

    it "should be true if the field is not on the page" do
      @session.should have_no_select('Monkey')
    end

    context 'with selected value' do
      it "should be false if a field with the given value is on the page" do
        @session.should_not have_no_select('form_locale', :selected => 'English')  
        @session.should_not have_no_select('Region', :selected => 'Norway')  
        @session.should_not have_no_select('Underwear', :selected => ['Briefs', 'Commando'])
      end

      it "should be true if the given field is not on the page" do
        @session.should have_no_select('Locale', :selected => 'Swedish')  
        @session.should have_no_select('Does not exist', :selected => 'John')  
        @session.should have_no_select('City', :selected => 'Not there')
        @session.should have_no_select('Underwear', :selected => ['Briefs', 'Nonexistant'])
        @session.should have_no_select('Underwear', :selected => ['Briefs', 'Boxers'])
      end
    end

    context 'with options' do
      it "should be false if a field with the given options is on the page" do
        @session.should_not have_no_select('form_locale', :options => ['English'])  
        @session.should_not have_no_select('Region', :options => ['Norway', 'Sweden'])  
      end

      it "should be true if the given field is not on the page" do
        @session.should have_no_select('Locale', :options => ['Not there'])
        @session.should have_no_select('Does not exist', :options => ['John'])  
        @session.should have_no_select('City', :options => ['London', 'Made up city'])
      end
    end
  end
end


