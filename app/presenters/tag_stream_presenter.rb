# frozen_string_literal: true

class TagStreamPresenter < BasePresenter
  def title
    @presentable.display_tag_name
  end

  def metas_attributes
    {
      keywords:       {name:     "keywords",       content: tag_names},
      description:    {name:     "description",    content: description},
      og_url:         {property: "og:url",         content: url},
      og_title:       {property: "og:title",       content: title},
      og_description: {property: "og:description", content: description}
    }
  end

  private

  def description
    I18n.t("streams.tags.title", tags: tag_names)
  end

  def url
    tag_url tag_names
  end
end
