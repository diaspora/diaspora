module PostGenerationHelpers

  def generate_post_of_each_template(user)
    time = Time.now

    TemplatePicker::TEMPLATES.each do |template|
      Timecop.travel time += 1.minute
      FactoryGirl.create(template, :author => user.person)
    end

    Timecop.return
  end

  def visit_posts_and_collect_template_names(user)
    visit(post_path(user.posts.last))
    user.posts.map do |post|
      sleep 0.25
      post = find('.post')
      template_name = post['data-template']
      click_next_button
      template_name
    end
  end

  def click_next_button
    next_arrow = '.nav-arrow.right'
    if page.has_selector?(next_arrow)
      find(next_arrow).click()
    end
  end
end

World(PostGenerationHelpers)
