module RSpec
  module Core
    module Subject
      module InstanceMethods

        # Returns the subject defined by the example group. The subject block is
        # only executed once per example, the result of which is cached and
        # returned by any subsequent calls to +subject+.
        #
        # If a class is passed to +describe+ and no subject is explicitly
        # declared in the example group, then +subject+ will return a new
        # instance of that class.
        #
        # == Examples
        #
        #   # explicit subject defined by the subject method
        #   describe Person do
        #     subject { Person.new(:birthdate => 19.years.ago) }
        #     it "should be eligible to vote" do
        #       subject.should be_eligible_to_vote
        #     end
        #   end
        #
        #   # implicit subject => { Person.new }
        #   describe Person do
        #     it "should be eligible to vote" do
        #       subject.should be_eligible_to_vote
        #     end
        #   end
        def subject
          @original_subject ||= instance_eval(&self.class.subject)
        end

        begin
          require 'rspec/expectations/extensions/kernel'
          alias_method :__should_for_example_group__,     :should
          alias_method :__should_not_for_example_group__, :should_not

          # When +should+ is called with no explicit receiver, the call is
          # delegated to the object returned by +subject+. Combined with
          # an implicit subject (see +subject+), this supports very concise
          # expressions.
          #
          # == Examples
          #
          #   describe Person do
          #     it { should be_eligible_to_vote }
          #   end
          def should(matcher=nil, message=nil)
            self == subject ? self.__should_for_example_group__(matcher) : subject.should(matcher,message)
          end

          # Just like +should+, +should_not+ delegates to the subject (implicit or
          # explicit) of the example group.
          #
          # == Examples
          #
          #   describe Person do
          #     it { should_not be_eligible_to_vote }
          #   end
          def should_not(matcher=nil, message=nil)
            self == subject ? self.__should_not_for_example_group__(matcher) : subject.should_not(matcher,message)
          end
        rescue LoadError
        end
      end

      module ClassMethods
        # Creates a nested example group named by the submitted +attribute+,
        # and then generates an example using the submitted block.
        #
        #   # This ...
        #   describe Array do
        #     its(:size) { should == 0 }
        #   end
        #
        #   # ... generates the same runtime structure as this:
        #   describe Array do
        #     describe "size" do
        #       it "should == 0" do
        #         subject.size.should == 0
        #       end
        #     end
        #   end
        #
        # The attribute can be a +Symbol+ or a +String+. Given a +String+
        # with dots, the result is as though you concatenated that +String+
        # onto the subject in an expression.
        #   
        #   describe Person do
        #     let(:person) do
        #       person = Person.new
        #       person.phone_numbers << "555-1212"
        #     end
        #
        #     its("phone_numbers.first") { should == "555-1212" }
        #   end
        #
        # When the subject is a +Hash+, you can refer to the Hash keys by
        # specifying a +Symbol+ or +String+ in an array.
        #
        #   describe "a configuration Hash" do
        #     subject do
        #       { :max_users => 3,
        #         'admin' => :all_permissions }
        #     end
        #
        #     its([:max_users]) { should == 3 }
        #     its(['admin']) { should == :all_permissions }
        #
        #     # You can still access to its regular methods this way:
        #     its(:keys) { should include(:max_users) }
        #     its(:count) { should == 2 }
        #   end
        def its(attribute, &block)
          describe(attribute) do
            example do
              self.class.class_eval do
                define_method(:subject) do
                  if super().is_a?(Hash) && attribute.is_a?(Array)
                    OpenStruct.new(super()).send(attribute.first)
                  else
                    attribute.to_s.split('.').inject(super()) do |target, method|
                      target.send(method)
                    end
                  end
                end
              end
              instance_eval(&block)
            end
          end
        end

        # Defines an explicit subject for an example group which can then be the
        # implicit receiver (through delegation) of calls to +should+.
        #
        # == Examples
        #
        #   describe CheckingAccount, "with $50" do
        #     subject { CheckingAccount.new(:amount => 50, :currency => :USD) }
        #     it { should have_a_balance_of(50, :USD) }
        #     it { should_not be_overdrawn }
        #   end
        #
        # See +ExampleMethods#should+ for more information about this approach.
        def subject(&block)
          block ? @explicit_subject_block = block : explicit_subject || implicit_subject
        end

        attr_reader :explicit_subject_block # :nodoc:

        private

        def explicit_subject
          group = self
          while group.respond_to?(:explicit_subject_block)
            return group.explicit_subject_block if group.explicit_subject_block
            group = group.superclass
          end
        end

        def implicit_subject
          described = describes || description
          Class === described ? proc { described.new } : proc { described }
        end
      end

    end
  end
end
