# frozen_string_literal: true

module MetaDataHelper
  include ActionView::Helpers::AssetUrlHelper
  include ActionView::Helpers::TagHelper

  def og_prefix
    'og: http://ogp.me/ns# article: http://ogp.me/ns/article# profile: http://ogp.me/ns/profile#'
  end

  def site_url
    AppConfig.environment.url
  end

  def default_image_url
    asset_url("assets/branding/logos/asterisk.png", skip_pipeline: true)
  end

  def default_author_name
    AppConfig.settings.pod_name
  end

  def default_description
    AppConfig.settings.default_metas.description
  end

  def default_title
    AppConfig.settings.default_metas.title
  end

  def general_metas
    {
      description:    {name:     "description",  content: default_description},
      og_description: {property: "description",  content: default_description},
      og_site_name:   {property: "og:site_name", content: default_title},
      og_url:         {property: "og:url",       content: site_url},
      og_image:       {property: "og:image",     content: default_image_url},
      og_type:        {property: "og:type",      content: "website"}
    }
  end

  def metas_tags(attributes_list={}, with_general_metas=true)
    attributes_list = general_metas.merge(attributes_list) if with_general_metas
    attributes_list.map {|_, attributes| meta_tag attributes }.join("\n").html_safe
  end

  # recursively calls itself if attribute[:content] is an array
  # (metas such as og:image or og:tag can be present multiple times with different values)
  def meta_tag(attributes)
    return "" if attributes.empty?
    return tag(:meta, attributes) unless attributes[:content].respond_to?(:to_ary)
    items = attributes.delete(:content)
    items.map {|item| meta_tag(attributes.merge(content: item)) }.join("\n")
  end
end
