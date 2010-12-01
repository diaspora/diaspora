require 'spec_helper'
require 'extlib/lazy_array'

# only needed for specs
require 'extlib/class'

module LazyArraySpec
  module GroupMethods
    def self.extended(base)
      base.class_inheritable_accessor :loaded, :subject_block, :action_block
    end

    def subject(&block)
       self.subject_block = block
    end

    def action(&block)
      self.action_block = block
    end

    def should_respond_to(method)
      unless loaded
        it { subject.should respond_to(method) }
      end
    end

    def should_return_expected_value(&block)
      it 'should return expected value' do
        action.should eql(instance_eval(&block))
      end
    end

    def should_return_subject
      should_return_kind_of(LazyArray)

      it 'should return self' do
        action.should equal(subject)
      end
    end

    def should_return_kind_of(klass)
      it { action.should be_a_kind_of(klass) }
    end

    def should_return_copy
      it 'should not return self' do
        action.should_not equal(subject)
      end

      it 'should eql self' do
        action.should eql(subject)
      end
    end

    def should_return_true
      it 'should return true' do
        action.should be_true
      end
    end

    def should_return_false
      it 'should return false' do
        action.should be_false
      end
    end

    def should_return_nil
      it 'should return nil' do
        action.should be_nil
      end
    end

    def should_raise_error(klass, message = nil)
      it { lambda { action }.should raise_error(klass, message) }
    end

    def should_clear_subject
      it 'should clear self' do
        lambda { action }.should change(subject, :empty?).from(false).to(true)
      end
    end

    def should_yield_to_each_entry
      it 'should yield to each entry' do
        lambda { action }.should change(@accumulator, :entries).from([]).to(subject.entries)
      end
    end

    def should_not_change_subject
      it 'should not change self' do
        # XXX: the following does not work with Array#delete_if, even when nothing removed (ruby bug?)
        #subject.freeze
        #lambda { action }.should_not raise_error(RUBY_VERSION >= '1.9.0' ? RuntimeError : TypeError)
        lambda { action }.should_not change(subject, :entries)
      end
    end

    def should_be_a_kicker
      unless loaded
        it 'should be a kicker' do
          lambda { action }.should change(subject, :loaded?).from(false).to(true)
        end
      end
    end

    def should_not_be_a_kicker
      unless loaded
        it 'should not be a kicker' do
          subject.should_not be_loaded
          lambda { action }.should_not change(subject, :loaded?)
        end
      end
    end
  end

  module Methods
    def subject
      @subject ||= instance_eval(&self.class.subject_block)
    end

    def action
      instance_eval(&self.class.action_block)
    end
  end
end

[ false, true ].each do |loaded|
  describe LazyArray do
    extend LazyArraySpec::GroupMethods
    include LazyArraySpec::Methods

    self.loaded = loaded

    # message describing the object state
    state = "(#{'not ' unless loaded}loaded)"

    before do
      @nancy  = 'nancy'
      @bessie = 'bessie'
      @steve  = 'steve'

      @lazy_array = LazyArray.new
      @lazy_array.load_with { |la| la.push(@nancy, @bessie) }

      @other = LazyArray.new
      @other.load_with { |la| la.push(@steve) }

      @lazy_array.entries if loaded
    end

    subject { @lazy_array }

    it 'should be an Enumerable' do
      (Enumerable === subject).should be_true
    end

    describe 'when frozen', state do
      before { subject.freeze }

      it 'should still be able to kick' do
        lambda { subject.entries }.should_not raise_error
      end

      it 'should not allow any modifications' do
        lambda { subject << @steve }.should raise_error(RUBY_VERSION >= '1.9.0' ? RuntimeError : TypeError)
      end
    end

    should_respond_to(:<<)

    describe '#<<' do
      action { subject << @steve }

      should_return_subject
      should_not_be_a_kicker

      it 'should append an entry' do
        (subject << @steve).should == [ @nancy, @bessie, @steve ]
      end
    end

    should_respond_to(:any?)

    describe '#any?', state do
      describe 'when not provided a block' do
        action { subject.any? }

        describe 'when the subject has entries that are not loaded' do
          should_return_true
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'when the subject has entries that are prepended' do
          subject { LazyArray.new.unshift(@nancy) }

          should_return_true
          should_not_be_a_kicker
          should_not_change_subject
        end

        describe 'when the subject has entries that are appended' do
          subject { LazyArray.new << @nancy }

          should_return_true
          should_not_be_a_kicker
          should_not_change_subject
        end

        describe 'when the subject has no entries' do
          subject { LazyArray.new }

          should_return_false
          should_be_a_kicker
          should_not_change_subject
        end
      end

      describe 'when provided a block that always returns true' do
        action { subject.any? { true } }

        describe 'when the subject has entries that are not loaded' do
          should_return_true
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'when the subject has entries that are prepended' do
          subject { LazyArray.new.unshift(@nancy) }

          should_return_true
          should_not_be_a_kicker
          should_not_change_subject
        end

        describe 'when the subject has entries that are appended' do
          subject { LazyArray.new << @nancy }

          should_return_true
          should_not_be_a_kicker
          should_not_change_subject
        end

        describe 'when the subject has no entries' do
          subject { LazyArray.new }

          should_return_false
          should_be_a_kicker
          should_not_change_subject
        end
      end
    end

    should_respond_to(:at)

    describe '#at', state do
      describe 'with positive index' do
        action { subject.at(0) }

        should_return_expected_value { @nancy }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with positive index', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.at(0) }

        should_return_expected_value { @steve }
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with negative index' do
        action { subject.at(-1) }

        should_return_expected_value { @bessie }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with negative index', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.at(-1) }

        should_return_expected_value { @steve }
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with an index not within the LazyArray' do
        action { subject.at(2) }

        should_return_nil
        should_be_a_kicker
        should_not_change_subject
      end
    end

    should_respond_to(:clear)

    describe '#clear', state do
      action { subject.clear }

      should_return_subject
      should_be_a_kicker  # only marks as loadd, does not lazy load
      should_clear_subject
    end

    [ :collect!, :map! ].each do |method|
      it { @lazy_array.should respond_to(method) }

      describe "##{method}", state do
        before { @accumulator = [] }

        action { subject.send(method) { |e| @accumulator << e; @steve } }

        should_return_subject
        should_yield_to_each_entry
        should_be_a_kicker

        it 'should update with the block results' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @steve, @steve ])
        end
      end
    end

    should_respond_to(:concat)

    describe '#concat', state do
      action { subject.concat(@other) }

      should_return_subject
      should_not_be_a_kicker

      it 'should concatenate other Enumerable' do
        subject.concat(@other).should == [ @nancy, @bessie, @steve ]
      end
    end

    should_respond_to(:delete)

    describe '#delete', state do
      describe 'with an object within the LazyArray', state do
        action { subject.delete(@nancy) }

        should_return_expected_value { @nancy }
        should_be_a_kicker

        it 'should remove the matching entry' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @bessie ])
        end
      end

      describe 'with an object not within the LazyArray', 'without a default block' do
        action { subject.delete(@steve) }

        should_return_nil
        should_not_change_subject
        should_be_a_kicker
      end

      describe 'with an object not within the LazyArray', 'with a default block' do
        action { subject.delete(@steve) { @steve } }

        should_return_expected_value { @steve }
        should_not_change_subject
        should_be_a_kicker
      end
    end

    should_respond_to(:delete_at)

    describe '#delete_at', state do
      describe 'with a positive index' do
        action { subject.delete_at(0) }

        should_return_expected_value { @nancy }
        should_be_a_kicker

        it 'should remove the matching entry' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @bessie ])
        end
      end

      describe 'with a positive index', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.delete_at(0) }

        should_return_expected_value { @steve }
        should_not_be_a_kicker

        it 'should remove the matching entry' do
          lambda { action }.should change(subject, :entries).from([ @steve, @nancy, @bessie ]).to([ @nancy, @bessie ])
        end
      end

      describe 'with a negative index' do
        action { subject.delete_at(-1) }

        should_return_expected_value { @bessie }
        should_be_a_kicker

        it 'should remove the matching entry' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy ])
        end
      end

      describe 'with a negative index', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.delete_at(-1) }

        should_return_expected_value { @steve }
        should_not_be_a_kicker

        it 'should remove the matching entry' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie, @steve ]).to([ @nancy, @bessie ])
        end
      end

      describe 'with an index not within the LazyArray' do
        action { subject.delete_at(2) }

        should_return_nil
        should_not_change_subject
        should_be_a_kicker
      end
    end

    should_respond_to(:delete_if)

    describe '#delete_if', state do
      before { @accumulator = [] }

      describe 'with a block that matches an entry' do
        action { subject.delete_if { |e| @accumulator << e; true } }

        should_return_subject
        should_yield_to_each_entry
        should_not_be_a_kicker

        it 'should update with the block results' do
          lambda { action }.should change(subject, :empty?).from(false).to(true)
        end
      end

      describe 'with a block that does not match an entry' do
        action { subject.delete_if { |e| @accumulator << e; false } }

        should_return_subject
        should_yield_to_each_entry
        should_not_be_a_kicker
        should_not_change_subject
      end
    end

    should_respond_to(:dup)

    describe '#dup', state do
      action { subject.dup }

      should_return_kind_of(LazyArray)
      should_return_copy
      should_not_be_a_kicker

      if loaded
        it 'should be loaded if subject loaded' do
          action.should be_loaded
        end
      end
    end

    should_respond_to(:each)

    describe '#each', state do
      before { @accumulator = [] }

      action { subject.each { |e| @accumulator << e } }

      should_return_subject
      should_yield_to_each_entry
      should_be_a_kicker
      should_not_change_subject
    end

    should_respond_to(:each_index)

    describe '#each_index', state do
      before { @accumulator = [] }

      action { subject.each_index { |i| @accumulator << i } }

      should_return_subject
      should_be_a_kicker
      should_not_change_subject

      it 'should yield to each index' do
        lambda { action }.should change(@accumulator, :entries).from([]).to([ 0, 1 ])
      end
    end

    should_respond_to(:each_with_index)

    describe '#each_with_index', state do
      before { @accumulator = [] }

      action { subject.each_with_index { |entry,index| @accumulator << [ entry, index ] } }

      should_return_subject
      should_be_a_kicker
      should_not_change_subject

      it 'should yield to each entry and index' do
        lambda { action }.should change(@accumulator, :entries).from([]).to([ [ @nancy, 0 ], [ @bessie, 1 ] ])
      end
    end

    should_respond_to(:empty?)

    describe '#empty?', state do
      describe 'when the subject has entries that are not loaded' do
        action { subject.empty? }

        should_return_false
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'when the subject has entries that are prepended' do
        subject { LazyArray.new.unshift(@nancy) }

        action { subject.empty? }

        should_return_false
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'when the subject has entries that are appended' do
        subject { LazyArray.new << @nancy }

        action { subject.empty? }

        should_return_false
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'when the subject has no entries' do
        subject { LazyArray.new }

        action { subject.empty? }

        should_return_true
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'when the subject has only nil entries' do
        subject { LazyArray.new << nil }

        action { subject.empty? }

        should_return_false
        should_not_be_a_kicker
        should_not_change_subject
      end

    end

    [ :eql?, :== ].each do |method|
      should_respond_to(method)

      describe "##{method}", state do
        describe 'with an Enumerable containing the same entries' do
          before do
            if method == :eql?
              @other = LazyArray.new
              @other.load_with { |la| la.push(@nancy, @bessie) }
            else
              @other = [ @nancy, @bessie ]
            end
          end

          action { subject.send(method, @other) }

          should_return_true
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'with an Enumerable containing different entries' do
          action { subject.send(method, @other) }

          should_return_false
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'with an Enumerable with different entries than in head' do
          before { subject.unshift(@nancy) }

          action { subject.send(method, [ @steve ]) }

          should_return_false
          should_not_be_a_kicker
          should_not_change_subject
        end

        describe 'with an Enumerable with different entries than in tail' do
          before { subject.push(@nancy) }

          action { subject.send(method, [ @steve ]) }

          should_return_false
          should_not_be_a_kicker
          should_not_change_subject
        end
      end
    end

    should_respond_to(:fetch)

    describe '#fetch', state do
      describe 'with positive index' do
        action { subject.fetch(0) }

        should_return_expected_value { @nancy }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with positive index', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.fetch(0) }

        should_return_expected_value { @steve }
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with negative index' do
        action { subject.fetch(-1) }

        should_return_expected_value { @bessie }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with negative index', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.fetch(-1) }

        should_return_expected_value { @steve }
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with an index not within the LazyArray' do
        action { subject.fetch(2) }

        should_raise_error(IndexError)
      end

      describe 'with an index not within the LazyArray and default' do
        action { subject.fetch(2, @steve) }

        should_return_expected_value { @steve }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with an index not within the LazyArray and default block' do
        action { subject.fetch(2) { @steve } }

        should_return_expected_value { @steve }
        should_be_a_kicker
        should_not_change_subject
      end
    end

    should_respond_to(:freeze)

    describe '#freeze', state do
      action { subject.freeze }

      should_return_subject
      should_not_be_a_kicker

      it { lambda { action }.should change(subject, :frozen?).from(false).to(true) }
    end

    should_respond_to(:first)

    describe '#first', state do
      describe 'with no arguments' do
        action { subject.first }

        should_return_expected_value { @nancy }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with no arguments', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.first }

        should_return_expected_value { @steve }
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with length specified' do
        action { subject.first(1) }

        it { action.should == [ @nancy ] }

        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with length specified', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.first(1) }

        it { action.should == [ @steve ] }

        should_not_be_a_kicker
        should_not_change_subject
      end
    end

    should_respond_to(:include?)

    describe '#include?', state do
      describe 'with an included entry' do
        action { subject.include?(@nancy) }

        should_return_true
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with an included entry', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.include?(@steve) }

        should_return_true
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with an included entry', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.include?(@steve) }

        should_return_true
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with an entry not included' do
        action { subject.include?(@steve) }

        should_return_false
        should_be_a_kicker
        should_not_change_subject
      end
    end

    should_respond_to(:index)

    describe '#index', state do
      describe 'with an included entry' do
        action { subject.index(@nancy) }

        should_return_expected_value { 0 }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with an included entry', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.index(@steve) }

        should_return_expected_value { 0 }
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with an included entry', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.index(@steve) }

        should_return_expected_value { 2 }
        should_be_a_kicker  # need to kick because first index could be in lazy array
        should_not_change_subject
      end

      describe 'with an entry not included' do
        action { subject.index(@steve) }

        should_return_nil
        should_be_a_kicker
        should_not_change_subject
      end
    end

    should_respond_to(:insert)

    describe '#insert', state do
      describe 'with an index of 0' do
        action { subject.insert(0, @steve) }

        should_return_subject
        should_not_be_a_kicker

        it 'should insert the entries before the index' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @steve, @nancy, @bessie ])
        end
      end

      describe 'with an positive index greater than the head size' do
        action { subject.insert(1, @steve) }

        should_return_subject
        should_be_a_kicker

        it 'should insert the entries before the index' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @steve, @bessie ])
        end
      end

      describe 'with an index of -1' do
        action { subject.insert(-1, @steve) }

        should_return_subject
        should_not_be_a_kicker

        it 'should insert the entries before the index' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @bessie, @steve ])
        end
      end

      describe 'with a negative index greater than the tail size' do
        action { subject.insert(-2, @steve) }

        should_return_subject
        should_be_a_kicker

        it 'should insert the entries before the index' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @steve, @bessie ])
        end
      end

      describe 'with a positive index 1 greater than the maximum index of the LazyArray' do
        action { subject.insert(2, @steve) }

        should_return_subject
        should_be_a_kicker

        it 'should insert the entries before the index' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @bessie, @steve ])
        end
      end

      describe 'with a positive index not within the LazyArray' do
        action { subject.insert(3, @steve) }

        should_return_subject
        should_be_a_kicker

        it 'should insert the entries before the index, expanding the LazyArray' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @bessie, nil, @steve ])
        end
      end

      describe 'with a negative index 1 greater than the maximum index of the LazyArray' do
        action { subject.insert(-3, @steve) }

        should_return_subject
        should_be_a_kicker

        it 'should insert the entries before the index, expanding the LazyArray' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @steve, @nancy, @bessie ])
        end
      end

      describe 'with a negative index not within the LazyArray' do
        action { subject.insert(-4, @steve) }

        should_raise_error(IndexError)
      end
    end

    should_respond_to(:kind_of?)

    describe '#kind_of' do
      describe 'when provided a class that is a superclass' do
        action { subject.kind_of?(Object) }

        should_return_true
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'when provided a class that is a proxy class superclass' do
        action { subject.kind_of?(Array) }

        should_return_true
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'when provided a class that is not a superclass' do
        action { subject.kind_of?(Hash) }

        should_return_false
        should_not_be_a_kicker
        should_not_change_subject
      end
    end

    should_respond_to(:last)

    describe '#last', state do
      describe 'with no arguments' do
        action { subject.last }

        should_return_expected_value { @bessie }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with no arguments', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.last }

        should_return_expected_value { @steve }
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with length specified' do
        action { subject.last(1) }

        it { action.should == [ @bessie ] }

        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with length specified', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.last(1) }

        it { action.should == [ @steve ] }

        should_not_be_a_kicker
        should_not_change_subject
      end
    end

    should_respond_to(:loaded?)

    describe '#loaded?' do
      if loaded
        describe 'when loaded' do
          action { subject.loaded? }

          should_return_true
          should_not_change_subject
        end
      else
        describe 'when not loaded' do
          action { subject.loaded? }

          should_return_false
          should_not_change_subject
        end
      end
    end

    should_respond_to(:nil?)

    describe '#nil?' do
      action { subject.nil? }

      should_return_expected_value { false }

      should_not_be_a_kicker
    end

    should_respond_to(:pop)

    describe '#pop', state do
      describe 'without appending to the LazyArray' do
        action { subject.pop }

        should_return_expected_value { @bessie }
        should_be_a_kicker

        it 'should remove the last entry' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy ])
        end
      end

      describe 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.pop }

        should_return_expected_value { @steve }
        should_not_be_a_kicker

        it 'should remove the last entry' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie, @steve ]).to([ @nancy, @bessie ])
        end
      end
    end

    should_respond_to(:push)

    describe '#push', state do
      action { subject.push(@steve, @steve) }

      should_return_subject
      should_not_be_a_kicker

      it 'should append entries' do
        lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @bessie, @steve, @steve ])
      end
    end

    should_respond_to(:reject!)

    describe '#reject!', state do
      before { @accumulator = [] }

      describe 'with a block that matches an entry' do
        action { subject.reject! { |e| @accumulator << e; true } }

        should_return_subject
        should_yield_to_each_entry
        should_be_a_kicker

        it 'should update with the block results' do
          lambda { action }.should change(subject, :empty?).from(false).to(true)
        end
      end

      describe 'with a block that does not match an entry' do
        action { subject.reject! { |e| @accumulator << e; false } }

        should_return_nil
        should_yield_to_each_entry
        should_be_a_kicker
        should_not_change_subject
      end
    end

    should_respond_to(:replace)

    describe '#replace' do
      action { subject.replace(@other) }

      should_return_subject
      should_be_a_kicker

      it 'should replace with other Enumerable' do
        lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @steve ])
      end
    end

    should_respond_to(:reverse)

    describe '#reverse', state do
      action { subject.reverse }

      should_return_kind_of(LazyArray)
      should_not_be_a_kicker
      should_not_change_subject

      it 'should return a reversed LazyArray' do
        action.should == [ @bessie, @nancy ]
      end
    end

    should_respond_to(:reverse!)

    describe '#reverse!', state do
      action { subject.reverse! }

      should_return_subject
      should_not_be_a_kicker

      it 'should return a reversed LazyArray' do
        action.should == [ @bessie, @nancy ]
      end
    end

    should_respond_to(:reverse_each)

    describe '#reverse_each', state do
      before { @accumulator = [] }

      action { subject.reverse_each { |e| @accumulator << e } }

      should_return_subject
      should_be_a_kicker
      should_not_change_subject

      it 'should yield to each entry' do
        lambda { action }.should change(@accumulator, :entries).from([]).to([ @bessie, @nancy ])
      end
    end

    should_respond_to(:rindex)

    describe '#rindex', state do
      describe 'with an included entry' do
        action { subject.rindex(@nancy) }

        should_return_expected_value { 0 }
        should_be_a_kicker  # rindex always a kicker
        should_not_change_subject
      end

      describe 'with an included entry', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.rindex(@steve) }

        should_return_expected_value { 0 }
        should_be_a_kicker  # rindex always a kicker
        should_not_change_subject
      end

      describe 'with an included entry', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.rindex(@steve) }

        should_return_expected_value { 2 }
        should_be_a_kicker  # rindex always a kicker
        should_not_change_subject
      end

      describe 'with an entry not included' do
        action { subject.rindex(@steve) }

        should_return_nil
        should_be_a_kicker  # rindex always a kicker
        should_not_change_subject
      end
    end

    should_respond_to(:shift)

    describe '#shift', state do
      describe 'without prepending to the LazyArray' do
        action { subject.shift }

        should_return_expected_value { @nancy }
        should_be_a_kicker

        it 'should remove the last entry' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @bessie ])
        end
      end

      describe 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.shift }

        should_return_expected_value { @steve }
        should_not_be_a_kicker

        it 'should remove the last entry' do
          lambda { action }.should change(subject, :entries).from([ @steve, @nancy, @bessie ]).to([ @nancy, @bessie ])
        end
      end
    end

    [ :slice, :[] ].each do |method|
      should_respond_to(method)

      describe "##{method}", state do
        describe 'with a positive index' do
          action { subject.send(method, 0) }

          should_return_expected_value { @nancy }
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'with a positive index', 'after prepending to the LazyArray' do
          before { subject.unshift(@steve) }

          action { subject.send(method, 0) }

          should_return_expected_value { @steve }
          should_not_be_a_kicker
          should_not_change_subject
        end

        describe 'with a positive index and length' do
          action { subject.send(method, 0, 1) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @nancy ] }
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'with a positive index and length', 'after prepending to the LazyArray' do
          before { subject.unshift(@steve) }

          action { subject.send(method, 0, 1) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @steve ] }
          should_not_be_a_kicker
          should_not_change_subject
        end

        describe 'with a positive range' do
          action { subject.send(method, 0..0) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @nancy ] }
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'with a positive range', 'after prepending to the LazyArray' do
          before { subject.unshift(@steve) }

          action { subject.send(method, 0..0) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @steve ] }
          should_not_be_a_kicker
          should_not_change_subject
        end

        describe 'with a negative index' do
          action { subject.send(method, -1) }

          should_return_expected_value { @bessie }
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'with a negative index', 'after appending to the LazyArray' do
          before { subject.push(@steve) }

          action { subject.send(method, -1) }

          should_return_expected_value { @steve }
          should_not_be_a_kicker
          should_not_change_subject
        end

        describe 'with a negative index and length' do
          action { subject.send(method, -1, 1) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @bessie ] }
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'with a negative index and length', 'after appending to the LazyArray' do
          before { subject.push(@steve) }

          action { subject.send(method, -1, 1) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @steve ] }
          should_not_be_a_kicker
          should_not_change_subject
        end

        describe 'with a negative range' do
          action { subject.send(method, -1..-1) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @bessie ] }
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'with a negative range', 'after appending to the LazyArray' do
          before { subject.push(@steve) }

          action { subject.send(method, -1..-1) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @steve ] }
          should_not_be_a_kicker
          should_not_change_subject
        end

        describe 'with an index not within the LazyArray' do
          action { subject.send(method, 2) }

          should_return_nil
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'with an index and length not within the LazyArray' do
          action { subject.send(method, 2, 1) }

          should_return_kind_of(Array)
          should_return_expected_value { [] }
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'with a range not within the LazyArray' do
          action { subject.send(method, 2..2) }

          should_return_kind_of(Array)
          should_return_expected_value { [] }
          should_be_a_kicker
          should_not_change_subject
        end

        describe 'with invalid arguments' do
          action { subject.send(method, 1, 1..1) }

          should_raise_error(ArgumentError)
        end
      end
    end

    should_respond_to(:slice!)

    describe '#slice!', state do
      describe 'with a positive index' do
        action { subject.slice!(0) }

        should_return_expected_value { @nancy }
        should_be_a_kicker

        it 'should remove the matching entry' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @bessie ])
        end
      end

      describe 'with a positive index', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.slice!(0) }

        should_return_expected_value { @steve }
        should_not_be_a_kicker

        it 'should remove the matching entry' do
          lambda { action }.should change(subject, :entries).from([ @steve, @nancy, @bessie ]).to([ @nancy, @bessie ])
        end
      end

      describe 'with a positive index and length' do
        action { subject.slice!(0, 1) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @nancy ] }
        should_be_a_kicker

        it 'should remove the matching entries' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @bessie ])
        end
      end

      describe 'with a positive index and length', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.slice!(0, 1) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @steve ] }
        should_not_be_a_kicker

        it 'should remove the matching entries' do
          lambda { action }.should change(subject, :entries).from([ @steve, @nancy, @bessie ]).to([ @nancy, @bessie ])
        end
      end

      describe 'with a positive range' do
        action { subject.slice!(0..0) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @nancy ] }
        should_be_a_kicker

        it 'should remove the matching entries' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @bessie ])
        end
      end

      describe 'with a positive range', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.slice!(0..0) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @steve ] }
        should_not_be_a_kicker

        it 'should remove the matching entry' do
          lambda { action }.should change(subject, :entries).from([ @steve, @nancy, @bessie ]).to([ @nancy, @bessie ])
        end
      end

      describe 'with a negative index' do
        action { subject.slice!(-1) }

        should_return_expected_value { @bessie }
        should_be_a_kicker

        it 'should remove the matching entries' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy ])
        end
      end

      describe 'with a negative index', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.slice!(-1) }

        should_return_expected_value { @steve }
        should_not_be_a_kicker

        it 'should remove the matching entries' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie, @steve ]).to([ @nancy, @bessie ])
        end
      end

      describe 'with a negative index and length' do
        action { subject.slice!(-1, 1) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @bessie ] }
        should_be_a_kicker

        it 'should remove the matching entries' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy ])
        end
      end

      describe 'with a negative index and length', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.slice!(-1, 1) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @steve ] }
        should_not_be_a_kicker

        it 'should remove the matching entries' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie, @steve ]).to([ @nancy, @bessie ])
        end
      end

      describe 'with a negative range' do
        action { subject.slice!(-1..-1) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @bessie ] }
        should_be_a_kicker

        it 'should remove the matching entries' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy ])
        end
      end

      describe 'with a negative range', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.slice!(-1..-1) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @steve ] }
        should_not_be_a_kicker

        it 'should remove the matching entries' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie, @steve ]).to([ @nancy, @bessie ])
        end
      end

      describe 'with an index not within the LazyArray' do
        action { subject.slice!(2) }

        should_return_nil
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with an index and length not within the LazyArray' do
        action { subject.slice!(2, 1) }

        should_return_kind_of(Array)
        should_return_expected_value { [] }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with a range not within the LazyArray' do
        action { subject.slice!(2..2) }

        should_return_kind_of(Array)
        should_return_expected_value { [] }
        should_be_a_kicker
        should_not_change_subject
      end
    end

    should_respond_to(:sort!)

    describe '#sort!', state do
      describe 'without a block' do
        action { subject.sort! }

        should_return_subject
        should_be_a_kicker

        it 'should sort the LazyArray inline using default sort order' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @bessie, @nancy ])
        end
      end

      describe 'without a block' do
        action { subject.sort! { |a,b| a <=> b } }

        should_return_subject
        should_be_a_kicker

        it 'should sort the LazyArray inline using block' do
          lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @bessie, @nancy ])
        end
      end
    end

    [ :splice, :[]= ].each do |method|
      should_respond_to(method)

      describe "##{method}", state do
        before do
          @jon = 'jon'
        end

        describe 'with a positive index and entry' do
          action { subject.send(method, 0, @jon) }

          should_return_expected_value { @jon }
          should_be_a_kicker

          it 'should change the matching entry' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @jon, @bessie ])
          end
        end

        describe 'with a positive index', 'after prepending to the LazyArray' do
          before { subject.unshift(@steve) }

          action { subject.send(method, 0, @jon) }

          should_return_expected_value { @jon }
          should_not_be_a_kicker

          it 'should change the matching entry' do
            lambda { action }.should change(subject, :entries).from([ @steve, @nancy, @bessie ]).to([ @jon, @nancy, @bessie ])
          end
        end

        describe 'with a positive index and length' do
          action { subject.send(method, 0, 1, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @jon, @bessie ])
          end
        end

        describe 'with a positive index and length', 'after prepending to the LazyArray' do
          before { subject.unshift(@steve) }

          action { subject.send(method, 0, 1, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_not_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @steve, @nancy, @bessie ]).to([ @jon, @nancy, @bessie ])
          end
        end

        describe 'with a positive range' do
          action { subject.send(method, 0..0, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @jon, @bessie ])
          end
        end

        describe 'with a positive range', 'after prepending to the LazyArray' do
          before { subject.unshift(@steve) }

          action { subject.send(method, 0..0, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_not_be_a_kicker

          it 'should change the matching entry' do
            lambda { action }.should change(subject, :entries).from([ @steve, @nancy, @bessie ]).to([ @jon, @nancy, @bessie ])
          end
        end

        describe 'with a negative index' do
          action { subject.send(method, -1, @jon) }

          should_return_expected_value { @jon }
          should_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @jon ])
          end
        end

        describe 'with a negative index', 'after appending to the LazyArray' do
          before { subject.push(@steve) }

          action { subject.send(method, -1, @jon) }

          should_return_expected_value { @jon }
          should_not_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie, @steve ]).to([ @nancy, @bessie, @jon ])
          end
        end

        describe 'with a negative index and length' do
          action { subject.send(method, -1, 1, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @jon ])
          end
        end

        describe 'with a negative index and length', 'after appending to the LazyArray' do
          before { subject.push(@steve) }

          action { subject.send(method, -1, 1, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_not_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie, @steve ]).to([ @nancy, @bessie, @jon ])
          end
        end

        describe 'with a negative range' do
          action { subject.send(method, -1..-1, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @jon ])
          end
        end

        describe 'with a negative range', 'after appending to the LazyArray' do
          before { subject.push(@steve) }

          action { subject.send(method, -1..-1, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_not_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie, @steve ]).to([ @nancy, @bessie, @jon ])
          end
        end

        describe 'with a positive index 1 greater than the maximum index of the LazyArray' do
          action { subject.send(method, 2, @jon) }

          should_return_expected_value { @jon }
          should_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @bessie, @jon ])
          end
        end

        describe 'with a positive index not within the LazyArray' do
          action { subject.send(method, 3, @jon) }

          should_return_expected_value { @jon }
          should_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @bessie, nil, @jon ])
          end
        end

        describe 'with a negative index not within the LazyArray' do
          action { subject.send(method, -3, @jon) }

          should_raise_error(IndexError)
        end

        describe 'with a positive index and length 1 greater than the maximum index of the LazyArray' do
          action { subject.send(method, 2, 1, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @bessie, @jon ])
          end
        end

        describe 'with a positive index and length not within the LazyArray' do
          action { subject.send(method, 3, 1, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @bessie, nil, @jon ])
          end
        end

        describe 'with a negative index and length not within the LazyArray ' do
          action { subject.send(method, -3, 1, [ @jon ]) }

          should_raise_error(IndexError)
        end

        describe 'with a positive range 1 greater than the maximum index of the LazyArray' do
          action { subject.send(method, 2..2, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @bessie, @jon ])
          end
        end

        describe 'with a positive range not within the LazyArray' do
          action { subject.send(method, 3..3, [ @jon ]) }

          should_return_kind_of(Array)
          should_return_expected_value { [ @jon ] }
          should_be_a_kicker

          it 'should change the matching entries' do
            lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @nancy, @bessie, nil, @jon ])
          end
        end

        describe 'with a negative range not within the LazyArray' do
          action { subject.send(method, -3..-3, [ @jon ]) }

          should_raise_error(RangeError)
        end
      end
    end

    should_respond_to(:to_a)

    describe '#to_a', state do
      action { subject.to_a }

      should_return_kind_of(Array)
      should_be_a_kicker

      it 'should be equivalent to self' do
        action.should == subject
      end
    end

    should_respond_to(:unshift)

    describe '#unshift', state do
      action { subject.unshift(@steve, @steve) }

      should_return_subject
      should_not_be_a_kicker

      it 'should prepend entries' do
        lambda { action }.should change(subject, :entries).from([ @nancy, @bessie ]).to([ @steve, @steve, @nancy, @bessie ])
      end
    end

    should_respond_to(:values_at)

    describe '#values_at', state do
      describe 'with a positive index' do
        action { subject.values_at(0) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @nancy ] }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with a positive index', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.values_at(0) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @steve ] }
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with a positive range' do
        action { subject.values_at(0..0) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @nancy ] }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with a positive range', 'after prepending to the LazyArray' do
        before { subject.unshift(@steve) }

        action { subject.values_at(0..0) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @steve ] }
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with a negative index' do
        action { subject.values_at(-1) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @bessie ] }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with a negative index', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.values_at(-1) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @steve ] }
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with a negative range' do
        action { subject.values_at(-1..-1) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @bessie ] }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with a negative range', 'after appending to the LazyArray' do
        before { subject.push(@steve) }

        action { subject.values_at(-1..-1) }

        should_return_kind_of(Array)
        should_return_expected_value { [ @steve ] }
        should_not_be_a_kicker
        should_not_change_subject
      end

      describe 'with an index not within the LazyArray' do
        action { subject.values_at(2) }

        should_return_kind_of(Array)
        should_return_expected_value { [ nil ] }
        should_be_a_kicker
        should_not_change_subject
      end

      describe 'with a range not within the LazyArray' do
        action { subject.values_at(2..2) }

        should_return_kind_of(Array)
        should_return_expected_value { [ nil ] }
        should_be_a_kicker
        should_not_change_subject
      end
    end

    describe 'a method mixed into Array' do
      before :all do
        Enumerable.class_eval do
          remove_method :lazy_spec if instance_methods(false).any? { |m| m.to_sym == :lazy_spec }
          def lazy_spec
            true
          end
        end
      end

      it 'should delegate to the Array' do
        subject.lazy_spec.should be_true
      end
    end

    describe 'an unknown method' do
      action { subject.unknown }

      should_raise_error(NoMethodError)
    end
  end
end
