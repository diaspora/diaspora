#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatisticsController < ApplicationController
  respond_to :html, :json
  use_bootstrap_for :statistics

  def statistics
    @statistics = StatisticsPresenter.new
    respond_to do |format|
      format.json { render json: @statistics }
      format.mobile { render layout: 'application' }
      format.html { render layout: 'with_header_with_footer' }
    end
  end
end