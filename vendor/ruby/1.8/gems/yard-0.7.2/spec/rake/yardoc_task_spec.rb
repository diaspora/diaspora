require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::Rake::YardocTask do
  before do
    @yardoc = YARD::CLI::Yardoc.new
    @yardoc.statistics = false
    @yardoc.use_document_file = false
    @yardoc.use_yardopts_file = false
    @yardoc.generate = false
    Templates::Engine.stub!(:render)
    Templates::Engine.stub!(:generate)
    YARD.stub!(:parse)
    YARD::CLI::Yardoc.stub!(:new).and_return(@yardoc)
    ::Rake.application.clear
  end
  
  def run
    ::Rake.application.tasks[0].invoke
  end
  
  describe '#initialize' do
    it "should allow separate rake task name to be set" do
      YARD::Rake::YardocTask.new(:notyardoc)
      ::Rake.application.tasks[0].name.should == "notyardoc"
    end
  end
  
  describe '#files' do
    it "should allow files to be set" do
      YARD::Rake::YardocTask.new do |t|
        t.files = ['a', 'b', 'c']
      end
      run
      @yardoc.files.should == %w(a b c)
    end
  end
  
  describe '#options' do
    it "should allow extra options to be set" do
      YARD::Rake::YardocTask.new do |t|
        t.options = ['--private', '--protected']
      end
      run
      @yardoc.visibilities.should == [:public, :private, :protected]
    end
  end
  
  describe '#before' do
    it "should allow before callback" do
      proc = lambda { }
      proc.should_receive(:call)
      @yardoc.should_receive(:run)
      YARD::Rake::YardocTask.new {|t| t.before = proc }
      run
    end
  end
  
  describe '#after' do
    it "should allow after callback" do
      proc = lambda { }
      proc.should_receive(:call)
      @yardoc.should_receive(:run)
      YARD::Rake::YardocTask.new {|t| t.after = proc }
      run
    end
    
    describe '#verifier' do
      it "should allow a verifier proc to be set" do
        verifier = Verifier.new
        @yardoc.should_receive(:run) do
          @yardoc.options[:verifier].should == verifier
        end
        YARD::Rake::YardocTask.new {|t| t.verifier = verifier }
        run
      end

      it "should override --query options" do
        verifier = Verifier.new
        @yardoc.should_receive(:run) do
          @yardoc.options[:verifier].should == verifier
        end
        YARD::Rake::YardocTask.new do |t| 
          t.options += ['--query', '@return']
          t.verifier = verifier
        end
        run
      end
    end
  end
end