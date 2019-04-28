# frozen_string_literal: true

describe Api::Paging::RestPaginatorBuilder do
  it "generates page response builder called with index-based pager" do
    params = ActionController::Parameters.new(page: "1", per_page: "20")
    pager = Api::Paging::RestPaginatorBuilder.new(alice.posts, nil).index_pager(params)
    expect(pager.is_a?(Api::Paging::RestPagedResponseBuilder)).to be_truthy
  end

  it "generates page response builder with time-based pager" do
    params = ActionController::Parameters.new(before: Time.current.iso8601)
    pager = Api::Paging::RestPaginatorBuilder.new(alice.posts, nil).time_pager(params)
    expect(pager.is_a?(Api::Paging::RestPagedResponseBuilder)).to be_truthy
  end
end
