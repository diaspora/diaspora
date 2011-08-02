shared_examples_for "a generic strategy" do
  it { should respond_to(:db)  }
end

shared_examples_for "a generic truncation strategy" do
  it { should respond_to(:start) }
  it { should respond_to(:clean) }
end

shared_examples_for "a generic transaction strategy" do
  it { should respond_to(:start) }
  it { should respond_to(:clean) }
end
