# frozen_string_literal: true

module PublishingCukeHelpers
  def write_in_publisher(txt)
    fill_in "status_message_text", with: txt
  end

  def append_to_publisher(txt)
    status_message_text = find("#status_message_text").value
    fill_in id: "status_message_text", with: "#{status_message_text} #{txt}"
    # trigger JavaScript event listeners
    find("#status_message_text").native.send_key(:end)
  end

  def upload_file_with_publisher(path)
    page.execute_script(%q{$("input[name='qqfile']").css("opacity", '1');})
    with_scope("#publisher-textarea-wrapper") do
      attach_file("qqfile", Rails.root.join(path).to_s)
      # wait for the image to be ready
      page.assert_selector(".publisher_photo.loading", count: 0)
    end
  end

  def make_post(text)
    write_in_publisher(text)
    submit_publisher
  end

  def visible_text_from_markdown(text)
    CGI.unescapeHTML(ActionController::Base.helpers.strip_tags(Diaspora::MessageRenderer.new(text).markdownified)).strip
  end

  def submit_publisher
    txt = find("#publisher #status_message_text").value
    find("#publisher .btn-primary").click
    # wait for the publisher to be closed
    expect(find("#publisher")["class"]).to include("closed")
    # wait for the content to appear
    expect(find("#main-stream")).to have_content(visible_text_from_markdown(txt))
  end

  def click_and_post(text)
    click_publisher
    make_post(text)
  end

  def click_publisher
    find("#status_message_text").click
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
      action = find(:css, "a.like").text
      find(:css, "a.like").click
      expect(find(:css, "a.like")).not_to have_text(action)
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
