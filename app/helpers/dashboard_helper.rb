module DashboardHelper

  def type_partial(post)
    class_name = post.class.name.to_s.underscore
    "#{class_name.pluralize}/pane"
  end

end
