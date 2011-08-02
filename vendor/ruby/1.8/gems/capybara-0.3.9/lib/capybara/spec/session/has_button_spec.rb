shared_examples_for "has_button" do  
  describe '#has_button?' do
    before do
      @session.visit('/form')
    end

    it "should be true if the given button is on the page" do
      @session.should have_button('med')
      @session.should have_button('crap321')
    end

    it "should be false if the given button is not on the page" do
      @session.should_not have_button('monkey')
    end
  end

  describe '#has_no_button?' do
    before do
      @session.visit('/form')
    end

    it "should be true if the given button is on the page" do
      @session.should_not have_no_button('med')
      @session.should_not have_no_button('crap321')
    end

    it "should be false if the given button is not on the page" do
      @session.should have_no_button('monkey')
    end
  end
end

