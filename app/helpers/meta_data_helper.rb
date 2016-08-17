module MetaDataHelper
  include ActionView::Helpers::AssetUrlHelper
  include ActionView::Helpers::TagHelper;

  def og_prefix
    'og: http://ogp.me/ns# article: http://ogp.me/ns/article# profile: http://ogp.me/ns/profile#'
  end

  def site_url
    AppConfig.environment.url
  end

  def default_image_url
    AppConfig.url_to asset_url('assets/branding/logos/asterisk.png')
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
      description:    { name:     'description'  , content: default_description },
      og_description: { property: 'description'  , content: default_description },
      og_site_name:   { property: 'og:site_name' , content: default_title       },
      og_url:         { property: 'og:url'       , content: site_url            },
      og_image:       { property: 'og:image'     , content: default_image_url   },
      og_type:        { property: 'og:type'      , content: 'website'           },
    }
  end

  def metas_tags(attributes_list = {}, with_general_metas = true)
    attributes_list = general_metas.merge(attributes_list) if with_general_metas
    attributes_list.map {|name,attributes| meta_tag attributes}.join("\n")
  end

  def meta_tag(attributes)
    return "" if attributes.empty?
    unless attributes[:content].respond_to?(:to_ary)
      return tag(:meta, attributes)
    end
    items = attributes.delete(:content)
    items.inject("") do |string, item|
      %{#{string}#{meta_tag attributes.merge({ content: item })}\n}
    end.chop
  end
end
