#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatisticsPresenter

  def as_json options={}
    base_data.merge(user_counts)
             .merge(post_counts)
             .merge(comment_counts)
             .merge(all_services)
             .merge(legacy_services) # Remove in 0.6
  end

  def base_data
    {
      'name' => name,
      'network' => 'Diaspora',
      'version' => version,
      'registrations_open' => open_registrations?,
      'services' => available_services
    }
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

  def user_counts
    return {} unless expose_user_counts?
    {
      'total_users' => total_users,
      'active_users_monthly' => monthly_users,
      'active_users_halfyear' => halfyear_users
    }
  end

  def expose_user_counts?
    AppConfig.privacy.statistics.user_counts?
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

  def post_counts
    return {} unless expose_posts_counts?
    {
      'local_posts' => local_posts
    }
  end

  def local_posts
    @local_posts ||= Post.where(type: "StatusMessage")
                         .joins(:author)
                         .where("owner_id IS NOT null")
                         .count
  end

  def expose_posts_counts?
    AppConfig.privacy.statistics.post_counts?
  end

  def comment_counts
    return {} unless expose_comment_counts?
    {
      'local_comments' => local_comments
    }
  end

  def expose_comment_counts?
    AppConfig.privacy.statistics.comment_counts?
  end


  def local_comments
    @local_comments ||= Comment.joins(:author)
                               .where("owner_id IS NOT null")
                               .count
  end

  def all_services_helper
    result = {}
    Configuration::KNOWN_SERVICES.each {|service, options|
      result[service.to_s] = AppConfig["services.#{service}.enable"]
    }
    result
  end

  def all_services
    @all_services ||= all_services_helper
  end

  def available_services
    Configuration::KNOWN_SERVICES.select {|service|
      AppConfig["services.#{service}.enable"]
    }.map(&:to_s)
  end

  def legacy_services
    Configuration::KNOWN_SERVICES.each_with_object({}) {|service, result|
      result[service.to_s] = AppConfig["services.#{service}.enable"]
    }
  end

end
