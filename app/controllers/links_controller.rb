# frozen_string_literal: true

class LinksController < ApplicationController
  def resolve
    entity = DiasporaLinkService.new(query).find_or_fetch_entity
    raise ActiveRecord::RecordNotFound if entity.nil?

    redirect_to url_for(entity)
  end

  private

  def query
    @query ||= params.fetch(:q)
  end
end
