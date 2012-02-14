module PublishingCukeHelpers
  def make_post(text)
    fill_in 'status_message_fake_text', :with => text
    click_button :submit
    wait_for_ajax_to_finish
  end

  def click_and_post(text)
    click_publisher
    make_post(text)
  end

  def click_publisher
    page.execute_script('
      $("#publisher").removeClass("closed");
      $("#publisher").find("textarea").focus();
    ')
  end

  def first_post_text
    find('.stream_element:first .post-content').text()
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

  def make_comment(text)
    fill_in "text", :with => text
    click_button :submit
  end

  def focus_comment_box
    find("a.focus_comment_textarea").click
  end

  def wait_for_ajax_to_finish(wait_time=15)
    wait_until(wait_time) { evaluate_script("$.active") == 0 }
  end

  def assert_nsfw(text)
    post = find_post_by_text(text)
    post.find(".nsfw-shield").should be_present
  end
end

World(PublishingCukeHelpers)
