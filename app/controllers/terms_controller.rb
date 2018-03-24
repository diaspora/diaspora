# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class TermsController < ApplicationController

  respond_to :html, :mobile

  def index
    partial_dir = Rails.root.join('app', 'views', 'terms')
    if partial_dir.join('terms.haml').exist? ||
        partial_dir.join('terms.erb').exist?
      render :terms
    else
      render :default
    end
  end

end
