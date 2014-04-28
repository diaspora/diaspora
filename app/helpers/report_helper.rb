#   Copyright (c) 2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ReportHelper
  def report_content(id, type)
    raw case type
      when 'post'
        t('report.post_label', title: link_to(post_page_title(Post.find_by_id(id)), post_path(id)))
      when 'comment'
        # comment_message is not html_safe. To prevent
        # cross-site-scripting we have to escape html
        t('report.comment_label', data: h(comment_message(Comment.find_by_id(id))))
    end
  end
end
