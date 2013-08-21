module PublishingCukeHelpers
  def make_post(text)
    fill_in 'status_message_fake_text', :with => text
    find(".creation").click
    page.should have_content text unless page.has_css? '.nsfw-shield'
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

  def expand_first_post
    within(".stream_element", match: :first) do
      find(".expander").click
      find(".expander", visible: false).should_not be_visible
    end
  end

  def first_post_collapsed?
    find(".stream_element .collapsible", match: :first).should have_css(".expander")
    find(".stream_element .collapsible", match: :first).has_selector?(".collapsed")
  end

  def first_post_expanded?
    find(".stream_element .expander", match: :first, visible: false).should_not be_visible
    find(".stream_element .collapsible", match: :first).has_no_selector?(".collapsed")
    find(".stream_element .collapsible", match: :first).has_selector?(".opened")
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
    post.find(".nsfw-shield").should be_present
  end
end

World(PublishingCukeHelpers)
