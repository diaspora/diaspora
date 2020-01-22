# frozen_string_literal: true

describe Api::Paging::RestPagedResponseBuilder do
  before do
    @pager = Api::Paging::IndexPaginator.new(alice.posts, 1, 5)
  end
  it "returns page of data" do
    builder = Api::Paging::RestPagedResponseBuilder.new(@pager, nil)
    response = builder.response
    expect(response[:links]).not_to be_nil
    expect(response[:data]).not_to be_nil
  end
end
