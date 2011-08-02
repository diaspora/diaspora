shared_examples_for "has_field" do  
  describe '#has_field' do
    before { @session.visit('/form') }

    it "should be true if the field is on the page" do
      @session.should have_field('Dog')
      @session.should have_field('form_description')
      @session.should have_field('Region')
    end

    it "should be false if the field is not on the page" do
      @session.should_not have_field('Monkey')
    end

    context 'with value' do
      it "should be true if a field with the given value is on the page" do
        @session.should have_field('First Name', :with => 'John')  
        @session.should have_field('Phone', :with => '+1 555 7021')  
        @session.should have_field('Street', :with => 'Sesame street 66')  
        @session.should have_field('Description', :with => 'Descriptive text goes here')
      end

      it "should be false if the given field is not on the page" do
        @session.should_not have_field('First Name', :with => 'Peter')  
        @session.should_not have_field('Wrong Name', :with => 'John')  
        @session.should_not have_field('Description', :with => 'Monkey')
      end
    end
  end

  describe '#has_no_field' do
    before { @session.visit('/form') }

    it "should be false if the field is on the page" do
      @session.should_not have_no_field('Dog')
      @session.should_not have_no_field('form_description')
      @session.should_not have_no_field('Region')
    end

    it "should be true if the field is not on the page" do
      @session.should have_no_field('Monkey')
    end

    context 'with value' do
      it "should be flase if a field with the given value is on the page" do
        @session.should_not have_no_field('First Name', :with => 'John')  
        @session.should_not have_no_field('Phone', :with => '+1 555 7021')  
        @session.should_not have_no_field('Street', :with => 'Sesame street 66')  
        @session.should_not have_no_field('Description', :with => 'Descriptive text goes here')
      end

      it "should be true if the given field is not on the page" do
        @session.should have_no_field('First Name', :with => 'Peter')  
        @session.should have_no_field('Wrong Name', :with => 'John')  
        @session.should have_no_field('Description', :with => 'Monkey')
      end
    end
  end

  describe '#has_checked_field?' do
    before { @session.visit('/form') }

    it "should be true if a checked field is on the page" do
      @session.should have_checked_field('gender_female')
      @session.should have_checked_field('Hamster')
    end

    it "should be false if an unchecked field is on the page" do
      @session.should_not have_checked_field('form_pets_cat')
      @session.should_not have_checked_field('Male')
    end

    it "should be false if no field is on the page" do
      @session.should_not have_checked_field('Does Not Exist')
    end
  end

  describe '#has_unchecked_field?' do
    before { @session.visit('/form') }

    it "should be false if a checked field is on the page" do
      @session.should_not have_unchecked_field('gender_female')
      @session.should_not have_unchecked_field('Hamster')
    end

    it "should be true if an unchecked field is on the page" do
      @session.should have_unchecked_field('form_pets_cat')
      @session.should have_unchecked_field('Male')
    end

    it "should be false if no field is on the page" do
      @session.should_not have_unchecked_field('Does Not Exist')
    end
  end
end

