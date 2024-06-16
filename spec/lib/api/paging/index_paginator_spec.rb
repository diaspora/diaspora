# frozen_string_literal: true

describe Api::Paging::IndexPaginator do
  before do
    (1..7).each do |i|
      public = ![1, 6].include?(i)
      alice.post(
        :status_message,
        text:   "Post #{i}",
        public: public
      )
    end
    @alice_search = alice.posts.where(public: true).order("id ASC")
    @limit = 2
  end

  it "goes through using direct paging" do
    pager = Api::Paging::IndexPaginator.new(@alice_search, 1, @limit)
    page = pager.page_data
    validate_page(page, :created_at, false)
    page_count = 0
    until page&.empty?
      page_count += 1
      pager = pager.next_page(false)
      page = pager.page_data
      validate_page(page, :created_at, false)
    end
    expect(page_count).to eq(3)
  end

  it "goes through using Query Parameter data" do
    page_num = 1
    pager = Api::Paging::IndexPaginator.new(@alice_search, page_num, @limit)
    page = pager.page_data
    validate_page(page, :created_at, false)
    page_count = 0
    until page&.empty?
      page_count += 1
      break unless pager.next_page

      np = pager.next_page.split("=").last.to_i
      pager = Api::Paging::IndexPaginator.new(@alice_search, np, @limit)
      page = pager.page_data
      validate_page(page, :created_at, false)
    end
    expect(page_count).to eq(3)
  end

  def validate_page(page, field, is_descending)
    expect(page.length).to be <= @limit
    last_value = nil
    page.each do |element|
      last_value ||= element[field]
      if is_descending
        expect(last_value).to be >= element[field]
      else
        expect(last_value).to be <= element[field]
      end
      last_value = element[field]
    end
  end
end
