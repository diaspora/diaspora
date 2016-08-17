module MetaDataHelper
  include ActionView::Helpers::AssetUrlHelper
  include ActionView::Helpers::TagHelper;

  def site_url
    AppConfig.environment.url
  end

  def default_image_url
    AppConfig.url_to asset_url('assets/branding/logos/asterisk.png')
  end

  def default_author_name
    AppConfig.settings.pod_name
  end

  def metas_tags(attributes_list)
    attributes_list.map {|attributes| meta_tag attributes}.join("\n")
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
