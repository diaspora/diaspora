# frozen_string_literal: true

#   Copyright (c) 2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ReportHelper
  # rubocop:disable Rails/OutputSafety
  def report_content(report)
    case (item = report.item)
    when Post
      raw t("report.post_label", content: link_to(post_page_title(item), post_path(item.id)))
    when Comment
      raw t("report.comment_label", data: link_to(item.message.title,
        post_path(item.post.id, anchor: item.guid)
      ))
    else
      t("report.not_found")
    end
  end

  # rubocop:enable Rails/OutputSafety

  def link_to_content(report)
    case (item = report.item)
    when Post
      link_to("", post_path(item.id),
              {title:  t("report.view_reported_element"),
               class:  "entypo-eye",
               target: "_blank",
               rel:    "noopener"})
    when Comment
      link_to("", post_path(item.post.id, anchor: item.guid),
              {title:  t("report.view_reported_element"),
               class:  "entypo-eye",
               target: "_blank",
               rel:    "noopener"})
    else
      t("report.not_found")
    end
  end

  def unreviewed_reports_count
    @unreviewed_reports_count ||= Report.where(reviewed: false).size
  end
end
