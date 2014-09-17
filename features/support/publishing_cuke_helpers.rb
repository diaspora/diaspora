module PublishingCukeHelpers
  def write_in_publisher(txt)
    fill_in 'status_message_fake_text', with: txt
  end

  def append_to_publisher(txt, input_selector='#status_message_fake_text')
    elem = find(input_selector, visible: false)
    elem.native.send_keys(' ' + txt)

    # make sure the other text field got the new contents
    expect(find('#status_message_text', visible: false).value).to include(txt)
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
    txt = find('#publisher #status_message_fake_text').value
    find('#publisher .creation').click
    # wait for the content to appear
    expect(page).to have_content(txt) unless page.has_css?('.nsfw-shield')
  end

  def click_and_post(text)
    click_publisher
    make_post(text)
  end

  def click_publisher
    page.execute_script('
     $("#publisher").removeClass("closed");
     $("#publisher").find("#status_message_fake_text").focus();
    ')
  end

  def publisher_submittable?
    submit_btn = find("#publisher input[type=submit]")
    !submit_btn[:disabled]
  end

  def expand_first_post
    within(".stream_element", match: :first) do
      find(".expander").click
      expect(has_css?(".expander")).to be false
    end
  end

  def first_post_collapsed?
    expect(find(".stream_element .collapsible", match: :first)).to have_css(".expander")
    expect(page).to have_css(".stream_element .collapsible.collapsed", match: :first)
  end

  def first_post_expanded?
    expect(page).to have_no_css(".stream_element .expander", match: :first)
    expect(page).to have_no_css(".stream_element .collapsible.collapsed", match: :first)
    expect(page).to have_css(".stream_element .collapsible.opened", match: :first)
  end

  def first_post_text
    find(".stream_element .post-content", match: :first).text
  end

  def frame_numbers_content(position)
    find(".stream-frame:nth-child(#{position}) .content")
  end

  def find_frame_by_text(text)
    find(".stream-frame:contains('#{text}')")
  end

  def stream_element_numbers_content(position)
    find(".stream_element:nth-child(#{position}) .post-content")
  end

  def find_post_by_text(text)
    expect(page).to have_text(text)
    find(".stream_element", text: text)
  end

  def like_post(post_text)
    within_post(post_text) do
      click_link 'Like'
    end
  end

  def within_post(post_text)
    within find_post_by_text(post_text) do
      yield
    end
  end

  def stream_posts
    all('.stream_element')
  end

  def comment_on_post(post_text, comment_text)
    within_post(post_text) do
      focus_comment_box
      make_comment(comment_text)
    end
    step %Q(I should see "#{comment_text}" within ".comment")
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
