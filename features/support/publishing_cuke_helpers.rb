module PublishingCukeHelpers
  def write_in_publisher(txt)
    fill_in 'status_message_fake_text', with: txt
  end

  def append_to_publisher(txt, input_selector='#status_message_fake_text')
    status_message_text = find("#status_message_text", visible: false).value
    find(input_selector).native.send_key(" #{txt}")

    # make sure the other text field got the new contents
    if input_selector == "#status_message_fake_text"
      begin
        expect(page).to have_selector("#status_message_text[value='#{status_message_text} #{txt}']", visible: false)
      rescue RSpec::Expectations::ExpectationNotMetError
        puts "Value was instead: #{find('#status_message_text', visible: false).value.inspect}"
        raise
      end
    end
  end

  def upload_file_with_publisher(path)
    page.execute_script(%q{$("input[name='file']").css("opacity", '1');})
    with_scope("#publisher_textarea_wrapper") do
      attach_file("file", Rails.root.join(path).to_s)
      # wait for the image to be ready
      page.assert_selector(".publisher_photo.loading", count: 0)
    end
  end

  def make_post(text)
    write_in_publisher(text)
    submit_publisher
  end

  def submit_publisher
    txt = find("#publisher #status_message_fake_text").value
    find("#publisher .btn-primary").click
    # wait for the content to appear
    expect(find("#main_stream")).to have_content(txt)
  end

  def click_and_post(text)
    click_publisher
    make_post(text)
  end

  def click_publisher
    find("#status_message_fake_text").click
    expect(find("#publisher")).to have_css(".publisher-textarea-wrapper.active")
  end

  def publisher_submittable?
    submit_btn = find("#publisher button#submit")
    !submit_btn[:disabled]
  end

  def expand_first_post
    within(".stream-element", match: :first) do
      find(".expander").click
      expect(page).to have_no_css(".expander")
    end
  end

  def first_post_collapsed?
    expect(find(".stream-element .collapsible", match: :first)).to have_css(".expander")
    expect(page).to have_css(".stream-element .collapsible.collapsed", match: :first)
  end

  def first_post_expanded?
    expect(page).to have_no_css(".stream-element .expander", match: :first)
    expect(page).to have_no_css(".stream-element .collapsible.collapsed", match: :first)
    expect(page).to have_css(".stream-element .collapsible.opened", match: :first)
  end

  def first_post_text
    find(".stream-element .post-content", match: :first).text
  end

  def frame_numbers_content(position)
    find(".stream-frame:nth-child(#{position}) .content")
  end

  def find_frame_by_text(text)
    find(".stream-frame:contains('#{text}')")
  end

  def stream_element_numbers_content(position)
    find(".stream-element:nth-child(#{position}) .post-content")
  end

  def find_post_by_text(text)
    expect(page).to have_text(text)
    find(".stream-element", text: text)
  end

  def within_post(post_text)
    within find_post_by_text(post_text) do
      yield
    end
  end

  def like_stream_post(post_text)
    within_post(post_text) do
      find(:css, 'a.like').click
    end
  end

  def like_show_page_post
    within("#single-post-actions") do
      find(:css, 'a.like').click
    end
  end

  def comment_on_show_page(comment_text)
    within("#single-post-interactions") do
      make_comment(comment_text)
    end
  end

  def make_comment(text, elem="text")
    fill_in elem, :with => text
    click_button "Comment"
  end

  def focus_comment_box(elem="a.focus_comment_textarea")
    find(elem).click
  end

  def assert_nsfw(text)
    post = find_post_by_text(text)
    expect(post.find(".nsfw-shield")).to be_present
  end
end

World(PublishingCukeHelpers)
