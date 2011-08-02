require "spec_helper"

module RSpec::Rails
  describe ViewExampleGroup do
    it { should be_included_in_files_in('./spec/views/') }
    it { should be_included_in_files_in('.\\spec\\views\\') }

    it "adds :type => :view to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include ViewExampleGroup
      end
      group.metadata[:type].should eq(:view)
    end

    describe 'automatic inclusion of helpers' do
      module ::ThingsHelper; end

      it 'includes the helper with the same name' do
        group = RSpec::Core::ExampleGroup.describe 'things/show.html.erb'
        group.should_receive(:helper).with(ThingsHelper)
        group.class_eval do
          include ViewExampleGroup
        end
      end

      it 'operates normally when no helper with the same name exists' do
        raise 'unexpected constant found' if Object.const_defined?('ClocksHelper')
        lambda {
          RSpec::Core::ExampleGroup.describe 'clocks/show.html.erb' do
            include ViewExampleGroup
          end
        }.should_not raise_error
      end

      context 'application helper exists' do
        before do
          if !Object.const_defined? 'ApplicationHelper'
            module ::ApplicationHelper; end
            @application_helper_defined = true
          end
        end

        after do
          if @application_helper_defined
            Object.__send__ :remove_const, 'ApplicationHelper'
          end
        end

        it 'includes the application helper' do
          group = RSpec::Core::Example.describe 'bars/new.html.erb'
          group.should_receive(:helper).with(ApplicationHelper)
          group.class_eval do
            include ViewExampleGroup
          end
        end
      end

      context 'no application helper exists' do
        before do
          if Object.const_defined? 'ApplicationHelper'
            @application_helper = ApplicationHelper
            Object.__send__ :remove_const, 'ApplicationHelper'
          end
        end

        after do
          if @application_helper
            ApplicationHelper = @application_helper
          end
        end

        it 'operates normally' do
          lambda {
            RSpec::Core::ExampleGroup.describe 'foos/edit.html.erb' do
              include ViewExampleGroup
            end
          }.should_not raise_error
        end
      end
    end

    describe "#render" do
      let(:view_spec) do
        Class.new do
          module Local
            def received
              @received ||= []
            end
            def render(options={}, local_assigns={}, &block)
              received << [options, local_assigns, block]
            end
            def _assigns
              {}
            end
          end
          include Local
          include ViewExampleGroup::InstanceMethods
        end.new
      end

      context "given no input" do
        it "sends render(:file => (described file)) to the view" do
          view_spec.stub(:_default_file_to_render) { "widgets/new.html.erb" }
          view_spec.render
          view_spec.received.first.should == [{:template => "widgets/new.html.erb"},{}, nil]
        end
      end

      context "given a string" do
        it "sends string as the first arg to render" do
          view_spec.render('arbitrary/path')
          view_spec.received.first.should == ["arbitrary/path", {}, nil]
        end
      end

      context "given a hash" do
        it "sends the hash as the first arg to render" do
          view_spec.render(:foo => 'bar')
          view_spec.received.first.should == [{:foo => "bar"}, {}, nil]
        end
      end
    end

    describe '#params' do
      let(:view_spec) do
        Class.new do
          include ViewExampleGroup::InstanceMethods
          def controller
            @controller ||= Object.new
          end
        end.new
      end

      it 'delegates to the controller' do
        view_spec.controller.should_receive(:params).and_return({})
        view_spec.params[:foo] = 1
      end
    end

    describe "#_controller_path" do
      let(:view_spec) do
        Class.new do
          include ViewExampleGroup::InstanceMethods
        end.new
      end
      context "with a common _default_file_to_render" do
        it "it returns the directory" do
          view_spec.stub(:_default_file_to_render).
            and_return("things/new.html.erb")
          view_spec.__send__(:_controller_path).
            should == "things"
        end
      end

      context "with a nested _default_file_to_render" do
        it "it returns the directory path" do
          view_spec.stub(:_default_file_to_render).
            and_return("admin/things/new.html.erb")
          view_spec.__send__(:_controller_path).
            should == "admin/things"
        end
      end
    end

    describe "#view" do
      let(:view_spec) do
        Class.new do
          include ViewExampleGroup::InstanceMethods
        end.new
      end

      it "delegates to _view" do
        view = double("view")
        view_spec.stub(:_view) { view }
        view_spec.view.should == view
      end
    end

    describe "#template" do
      let(:view_spec) do
        Class.new do
          include ViewExampleGroup::InstanceMethods
          def _view; end
        end.new
      end

      before { RSpec.stub(:deprecate) }

      it "is deprecated" do
        RSpec.should_receive(:deprecate)
        view_spec.template
      end

      it "delegates to #view" do
        view_spec.should_receive(:view)
        view_spec.template
      end
    end
  end
end
