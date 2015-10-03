#   Copyright (c) 2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ReportHelper
  def report_content(report)
    case (item = report.item)
    when Post
      raw t("report.post_label", title: link_to(post_page_title(item), post_path(item.id)))
    when Comment
      raw t("report.comment_label", data: link_to(
        h(comment_message(item)),
        post_path(item.post.id, anchor: item.author.guid)
      ))
    else
      raw t("report.not_found")
    end
  end
end
