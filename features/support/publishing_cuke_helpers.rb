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

  def wait_for_ajax_to_finish(wait_time=15)
    wait_until(wait_time) { evaluate_script("$.active") == 0 }
  end

  def assert_nsfw(text)
    post = find_post_by_text(text)
    post.find(".shield").should be_present
  end
end

World(PublishingCukeHelpers)