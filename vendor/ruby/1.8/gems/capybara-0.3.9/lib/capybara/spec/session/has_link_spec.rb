shared_examples_for "has_link" do

  describe '#has_link?' do
    before do
      @session.visit('/with_html')
    end

    it "should be true if the given link is on the page" do
      @session.should have_link('foo')
      @session.should have_link('awesome title')
    end

    it "should be false if the given link is not on the page" do
      @session.should_not have_link('monkey')
    end
  end

  describe '#has_no_link?' do
    before do
      @session.visit('/with_html')
    end

    it "should be false if the given link is on the page" do
      @session.should_not have_no_link('foo')
      @session.should_not have_no_link('awesome title')
    end

    it "should be true if the given link is not on the page" do
      @session.should have_no_link('monkey')
    end
  end
end

