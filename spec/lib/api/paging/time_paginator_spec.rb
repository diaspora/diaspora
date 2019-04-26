# frozen_string_literal: true

describe Api::Paging::TimePaginator do
  before do
    (1..7).each do |i|
      public = ![1, 6].include?(i)
      alice.post(
        :status_message,
        text:   "Post #{i}",
        public: public
      )
      Timecop.travel(1.hour.from_now)
    end
    @alice_search = alice.posts.where(public: true)
    @limit = 2
  end

  it "goes through decending using direct paging" do
    pager = Api::Paging::TimePaginator.new(
      query_base:       @alice_search,
      query_time_field: :created_at,
      data_time_field:  :created_at,
      current_time:     Time.current,
      is_descending:    true,
      limit:            @limit
    )
    page = pager.page_data
    last_time = validate_page(page, :created_at, true, nil)
    while page&.empty?
      pager = pager.next_page(false)
      page = pager.page_data
      last_time = validate_page(page, :created_at, true, last_time)
    end
  end

  it "goes through descending using Query Parameter data" do
    pager = Api::Paging::TimePaginator.new(
      query_base:       @alice_search,
      query_time_field: :created_at,
      data_time_field:  :created_at,
      current_time:     Time.current,
      is_descending:    true,
      limit:            @limit
    )
    page = pager.page_data
    last_time = validate_page(page, :created_at, true, nil)
    while page&.empty?
      next_time = Time.iso8601(pager.next_page.split("=").last)
      pager = Api::Paging::TimePaginator.new(
        query_base:       @alice_search,
        query_time_field: :created_at,
        data_time_field:  :created_at,
        current_time:     next_time,
        is_descending:    true,
        limit:            @limit
      )
      page = pager.page_data
      last_time = validate_page(page, :created_at, true, last_time)
    end
  end

  it "goes through ascending using direct paging" do
    pager = Api::Paging::TimePaginator.new(
      query_base:       @alice_search,
      query_time_field: :created_at,
      data_time_field:  :created_at,
      current_time:     (Time.current - 1.year),
      is_descending:    false,
      limit:            @limit
    )
    page = pager.page_data
    last_time = validate_page(page, :created_at, false, nil)
    while page&.empty?
      pager = pager.next_page(false)
      page = pager.page_data
      last_time = validate_page(page, :created_at, false, last_time)
    end
  end

  it "goes through ascending using Query Parameter data" do
    pager = Api::Paging::TimePaginator.new(
      query_base:       @alice_search,
      query_time_field: :created_at,
      data_time_field:  :created_at,
      current_time:     (Time.current - 1.year),
      is_descending:    false,
      limit:            @limit
    )
    page = pager.page_data
    last_time = validate_page(page, :created_at, false, nil)
    while page&.empty?
      next_time = Time.iso8601(pager.next_page.split("=").last)
      pager = Api::Paging::TimePaginator.new(
        query_base:       @alice_search,
        query_time_field: :created_at,
        data_time_field:  :created_at,
        current_time:     next_time,
        is_descending:    false,
        limit:            @limit
      )
      page = pager.page_data
      last_time = validate_page(page, :created_at, false, last_time)
    end
  end

  def validate_page(page, field, is_descending, last_time)
    expect(page.length).to be <= @limit
    page.each do |element|
      last_time ||= element[field]
      if is_descending
        expect(last_time).to be >= element[field]
      else
        expect(last_time).to be <= element[field]
      end
      last_time = element[field]
    end
    last_time
  end
end
