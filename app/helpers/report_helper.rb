# frozen_string_literal: true

#   Copyright (c) 2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ReportHelper
  def report_content(report)
    case (item = report.item)
    when Post
      raw t("report.post_label", content: link_to(post_message(item), post_path(item.id)))
    when Comment
      raw t("report.comment_label", data: link_to(
        h(comment_message(item)),
        post_path(item.post.id, anchor: item.guid)
      ))
    else
      t("report.not_found")
    end
  end

  def unreviewed_reports_count
    @unreviewed_reports_count ||= Report.where(reviewed: false).size
  end
end
