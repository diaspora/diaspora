#   Copyright (c) 2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ReportHelper
  def report_content(id, type)
    if type == 'post' && !(post = Post.find_by_id(id)).nil?
      raw t('report.post_label', title: link_to(post_page_title(post), post_path(id)))
    elsif type == 'comment' && !(comment = Comment.find_by_id(id)).nil?
      # comment_message is not html_safe. To prevent
      # cross-site-scripting we have to escape html
      raw t('report.comment_label', data: h(comment_message(comment)))
    else
      raw t('report.not_found')
    end
  end
end
