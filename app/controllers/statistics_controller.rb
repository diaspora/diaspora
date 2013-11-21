#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class StatisticsController < ApplicationController

  respond_to :json
  
  def statistics
    respond_to do |format|
      format.json { render :json => StatisticsPresenter.new }
    end
  end
  
end
