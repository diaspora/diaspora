class Rails::InfoController < ActionController::Base
  def properties
    if consider_all_requests_local? || request.local?
      render :inline => Rails::Info.to_html
    else
      render :text => '<p>For security purposes, this information is only available to local requests.</p>', :status => :forbidden
    end
  end

  protected

  def consider_all_requests_local?
    Rails.application.config.consider_all_requests_local
  end
end
