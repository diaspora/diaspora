describe "the palindromic fixture", :shared => true do
  attr_reader :list, :node
  include IntervalSkipListSpecHelper

  before do
    @list = IntervalSkipList.new
  end

  it_should_behave_like "#next_node_height is deterministic"
  def expected_node_heights
    [3, 2, 1, 3, 1, 2, 3]
  end

  before do
    list.insert(1..3, :a)
    list.insert(1..5, :b)
    list.insert(1..7, :c)
    list.insert(1..9, :d)
    list.insert(1..11, :e)
    list.insert(1..13, :f)
    list.insert(5..13, :g)
  end
end