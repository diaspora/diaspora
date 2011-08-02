shared_examples_for "metadata hash builder" do
  context "when RSpec.configuration.treat_symbols_as_metadata_keys_with_true_values is set to true" do
    let(:hash) { metadata_hash(:foo, :bar, :bazz => 23) }

    before(:each) do
      RSpec.configure { |c| c.treat_symbols_as_metadata_keys_with_true_values = true }
    end

    it 'treats symbols as metadata keys with a true value' do
      hash[:foo].should == true
      hash[:bar].should == true
    end

    it 'still processes hash values normally' do
      hash[:bazz].should == 23
    end
  end

  context "when RSpec.configuration.treat_symbols_as_metadata_keys_with_true_values is set to false" do
    let(:warning_receiver) { Kernel }

    before(:each) do
      RSpec.configure { |c| c.treat_symbols_as_metadata_keys_with_true_values = false }
      warning_receiver.stub(:warn)
    end

    it 'prints a deprecation warning about any symbols given as arguments' do
      warning_receiver.should_receive(:warn).with(/In RSpec 3, these symbols will be treated as metadata keys/)
      metadata_hash(:foo, :bar, :key => 'value')
    end

    it 'does not treat symbols as metadata keys' do
      metadata_hash(:foo, :bar, :key => 'value').should_not include(:foo, :bar)
    end

    it 'does not print a warning if there are no symbol arguments' do
      warning_receiver.should_not_receive(:warn)
      metadata_hash(:foo => 23, :bar => 17)
    end
  end
end
