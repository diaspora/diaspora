class HotlinksController < ApplicationController

  def log_referrer
    raise "Image being hotlinked from: #{request.referrer}"
  end

end