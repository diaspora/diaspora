require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Capybara::XPath do

  before do
    @driver = Capybara::Driver::RackTest.new(TestApp)
    @driver.visit('/form')
    @xpath = Capybara::XPath.new
  end
  
  it "should proxy any class method calls to a new instance" do
    @query = Capybara::XPath.fillable_field('First Name').to_s
    @driver.find(@query).first.value.should == 'John'
  end
  
  it "should respond to instance methods at the class level" do
    Capybara::XPath.should respond_to(:fillable_field)
  end
  
  describe '.wrap' do
    it "should return an XPath unmodified" do
      Capybara::XPath.wrap(@xpath).should == @xpath
    end
    
    it "should wrap a string in an xpath object" do
      @xpath = Capybara::XPath.wrap('//foo/bar')
      @xpath.should be_an_instance_of(Capybara::XPath)
      @xpath.paths.should == ['//foo/bar']
    end
  end
  
  describe '#append' do
    it "should append an XPath's paths" do
      @xpath = Capybara::XPath.wrap('//test')
      @xpath = @xpath.append(Capybara::XPath.wrap('//foo/bar'))
      @xpath.paths.should == ['//test', '//foo/bar']
    end
    
    it "should append an String as a new path" do
      @xpath = Capybara::XPath.wrap('//test')
      @xpath = @xpath.append('//foo/bar')
      @xpath.paths.should == ['//test', '//foo/bar']
    end
  end
  
  describe '#prepend' do
    it "should prepend an XPath's paths" do
      @xpath = Capybara::XPath.wrap('//test')
      @xpath = @xpath.prepend(Capybara::XPath.wrap('//foo/bar'))
      @xpath.paths.should == ['//foo/bar', '//test']
    end
    
    it "should prepend an String as a new path" do
      @xpath = Capybara::XPath.wrap('//test')
      @xpath = @xpath.prepend('//foo/bar')
      @xpath.paths.should == ['//foo/bar', '//test']
    end
  end
  
  describe '#scope' do
    it "should prepend the given scope to all paths" do
      @xpath = Capybara::XPath.new('//foo/bar', '//test[@blah=foo]').scope('//quox')
      @xpath.paths.should include('//quox//foo/bar', '//quox//test[@blah=foo]')
    end
  end

  describe '#field' do
    it "should find any field by id or label" do
      @query = @xpath.field('First Name').to_s
      @driver.find(@query).first.value.should == 'John'
      @query = @xpath.field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
      @query = @xpath.field('Description').to_s
      @driver.find(@query).first.text.should == 'Descriptive text goes here'
      @query = @xpath.field('Document').to_s
      @driver.find(@query).first[:name].should == 'form[document]'
      @query = @xpath.field('Cat').to_s
      @driver.find(@query).first.value.should == 'cat'
      @query = @xpath.field('Male').to_s
      @driver.find(@query).first.value.should == 'male'
      @query = @xpath.field('Region').to_s
      @driver.find(@query).first[:name].should == 'form[region]'
    end
    
    it "should be chainable" do
      @query = @xpath.field('First Name').button('Click me!').to_s
      @driver.find(@query).first.value.should == 'John'
    end
  end
  
  describe '#fillable_field' do
    it "should find a text field, password field, or text area by id or label" do
      @query = @xpath.fillable_field('First Name').to_s
      @driver.find(@query).first.value.should == 'John'
      @query = @xpath.fillable_field('Password').to_s
      @driver.find(@query).first.value.should == 'seeekrit'
      @query = @xpath.fillable_field('Description').to_s
      @driver.find(@query).first.text.should == 'Descriptive text goes here'
    end

    it "should be chainable" do
      @query = @xpath.fillable_field('First Name').button('Click me!').to_s
      @driver.find(@query).first.value.should == 'John'
    end
  end

  describe '#text_area' do
    it "should find a text area by id or label" do
      @query = @xpath.text_area('form_description').to_s
      @driver.find(@query).first.text.should == 'Descriptive text goes here'
      @query = @xpath.text_area('Description').to_s
      @driver.find(@query).first.text.should == 'Descriptive text goes here'
    end
    
    it "should be chainable" do
      @query = @xpath.text_area('Description').button('Click me!').to_s
      @driver.find(@query).first.text.should == 'Descriptive text goes here'
    end
  end

  describe '#button' do
    it "should find a button by id or content" do
      @query = @xpath.button('awe123').to_s
      @driver.find(@query).first.value.should == 'awesome'
      @query = @xpath.button('okay556').to_s
      @driver.find(@query).first.value.should == 'okay'
      @query = @xpath.button('click_me_123').to_s
      @driver.find(@query).first.value.should == 'click_me'
      @query = @xpath.button('Click me!').to_s
      @driver.find(@query).first.value.should == 'click_me'
      @query = @xpath.button('fresh_btn').to_s
      @driver.find(@query).first.value.should == 'i am fresh'
      @query = @xpath.button('i am fresh').to_s
      @driver.find(@query).first[:name].should == 'form[fresh]'
    end
  end
  
  describe '#radio_button' do
    it "should find a radio button by id or label" do
      @query = @xpath.radio_button('Male').to_s
      @driver.find(@query).first.value.should == 'male'
      @query = @xpath.radio_button('gender_male').to_s
      @driver.find(@query).first.value.should == 'male'
    end
    
    it "should be chainable" do
      @query = @xpath.radio_button('Male').button('Click me!').to_s
      @driver.find(@query).first.value.should == 'male'
    end
  end
  
  describe '#checkbox' do
    it "should find a checkbox by id or label" do
      @query = @xpath.checkbox('Cat').to_s
      @driver.find(@query).first.value.should == 'cat'
      @query = @xpath.checkbox('form_pets_cat').to_s
      @driver.find(@query).first.value.should == 'cat'
    end
    
    it "should be chainable" do
      @query = @xpath.checkbox('Cat').button('Click me!').to_s
      @driver.find(@query).first.value.should == 'cat'
    end
  end

  describe '#select' do
    it "should find a select by id or label" do
      @query = @xpath.select('Region').to_s
      @driver.find(@query).first[:name].should == 'form[region]'
      @query = @xpath.select('form_region').to_s
      @driver.find(@query).first[:name].should == 'form[region]'
    end
    
    it "should be chainable" do
      @query = @xpath.select('Region').button('Click me!').to_s
      @driver.find(@query).first[:name].should == 'form[region]'
    end
  end
  
end
