# frozen_string_literal: true

class NodeInfoPresenter
  delegate :as_json, :content_type, to: :document

  def initialize(version)
    @version = version
  end

  def document
    @document ||= NodeInfo.build do |doc|
      doc.version = @version

      add_static_data doc
      add_configuration doc
      add_user_counts doc.usage.users
      add_usage doc.usage
    end
  end

  def add_configuration(doc)
    doc.software.version         = version
    doc.services.outbound        = available_services
    doc.open_registrations       = open_registrations?
    doc.metadata["nodeName"]     = name
    doc.metadata["xmppChat"]     = chat_enabled?
    doc.metadata["camo"]         = camo_config
    doc.metadata["adminAccount"] = admin_account
  end

  def add_static_data(doc)
    doc.software.name = "diaspora"
    doc.protocols.protocols << "diaspora"
  end

  def add_user_counts(doc)
    return unless expose_user_counts?

    doc.total           = total_users
    doc.active_halfyear = halfyear_users
    doc.active_month    = monthly_users
  end

  def add_usage(doc)
    doc.local_posts    = local_posts    if expose_posts_counts?
    doc.local_comments = local_comments if expose_comment_counts?
  end

  def expose_user_counts?
    AppConfig.privacy.statistics.user_counts?
  end

  def expose_posts_counts?
    AppConfig.privacy.statistics.post_counts?
  end

  def expose_comment_counts?
    AppConfig.privacy.statistics.comment_counts?
  end

  def name
    AppConfig.settings.pod_name
  end

  def version
    AppConfig.version_string
  end

  def open_registrations?
    AppConfig.settings.enable_registrations?
  end

  def chat_enabled?
    AppConfig.chat.enabled?
  end

  def camo_config
    {
      markdown:   AppConfig.privacy.camo.proxy_markdown_images?,
      opengraph:  AppConfig.privacy.camo.proxy_opengraph_thumbnails?,
      remotePods: AppConfig.privacy.camo.proxy_remote_pod_images?
    }
  end

  def admin_account
    AppConfig.admins.account if AppConfig.admins.account?
  end

  def available_services
    Configuration::KNOWN_SERVICES.select {|service|
      AppConfig.show_service?(service, nil)
    }.map(&:to_s)
  end

  def total_users
    @total_users ||= User.active.count
  end

  def monthly_users
    @monthly_users ||= User.monthly_actives.count
  end

  def halfyear_users
    @halfyear_users ||= User.halfyear_actives.count
  end

  def local_posts
    @local_posts ||= Post.where(type: "StatusMessage")
                         .joins(:author)
                         .where("owner_id IS NOT null")
                         .count
  end

  def local_comments
    @local_comments ||= Comment.joins(:author)
                               .where("owner_id IS NOT null")
                               .count
  end
end
