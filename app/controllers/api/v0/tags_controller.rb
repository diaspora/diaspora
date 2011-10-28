#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Api::V0::TagsController < ApplicationController
  def show
    render :json => Api::V0::Serializers::Tag.new(params[:name])
  end
end
