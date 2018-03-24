# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :authenticate_user!

  def search
    if search_query.starts_with?('#')
      if search_query.length > 1
        respond_to do |format|
          format.json {redirect_to tags_path(:q => search_query.delete("#."))}
          format.any {redirect_to tag_path(:name => search_query.delete("#."))}
        end
      else
        flash[:error] = I18n.t('tags.show.none', :name => search_query)
        redirect_back fallback_location: stream_path
      end
    else
      redirect_to people_path(:q => search_query)
    end
  end

  private

  def search_query
    @search_query ||= (params[:q] || params[:term] || '').strip
  end

end
