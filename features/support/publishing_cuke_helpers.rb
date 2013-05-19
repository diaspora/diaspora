module PublishingCukeHelpers
  def make_post(text)
    fill_in 'status_message_fake_text', :with => text
    find(".creation").click
    wait_for_ajax_to_finish
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
    find(".stream_element:first .expander").click
    wait_until{ !find(".expander").visible? }
  end

  def first_post_collapsed?
    find(".stream_element:first .collapsible").should have_css(".expander")
    find(".stream_element:first .collapsible").has_selector?(".collapsed")
  end

  def first_post_expanded?
    find(".stream_element:first .expander").should_not be_visible
    find(".stream_element:first .collapsible").has_no_selector?(".collapsed")
    find(".stream_element:first .collapsible").has_selector?(".opened")
  end

  def first_post_text
    stream_element_numbers_content(1).text()
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
    find(".stream_element:contains('#{text}')")
  end

  def like_post(post_text)
    within_post(post_text) do
      click_link 'Like'
    end
    wait_for_ajax_to_finish
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
    wait_for_ajax_to_finish
  end

  def comment_on_show_page(comment_text)
    within("#post-interactions") do
      focus_comment_box(".label.comment")
      make_comment(comment_text, "new-comment-text")
    end
    wait_for_ajax_to_finish
  end

  def make_comment(text, elem="text")
    fill_in elem, :with => text
    click_button :submit
  end

  def focus_comment_box(elem="a.focus_comment_textarea")
    find(elem).click
  end

  def wait_for_ajax_to_finish(wait_time=30)
    wait_until(wait_time) do
      evaluate_script("$.active") == 0
    end
  end

  def assert_nsfw(text)
    post = find_post_by_text(text)
    post.find(".nsfw-shield").should be_present
  end
end

World(PublishingCukeHelpers)
