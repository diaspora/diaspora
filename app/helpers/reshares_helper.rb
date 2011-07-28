module ResharesHelper
  def reshare_error_message(reshare)
    if @reshare.errors[:root_guid].present?
      escape_javascript(@reshare.errors[:root_guid].first)
    else
      escape_javascript(t('reshares.create.failure'))
    end
  end

  def reshare_link(post)
    if reshare?(post)
      link_to t("reshares.reshare.reshare_original"), reshares_path(:root_guid => post.root.guid), :method => :post, :remote => true, :confirm => t('reshares.reshare.reshare_confirmation', :author => post.root.author.name)
    else
      link_to t("reshares.reshare.reshare", :count => post.reshares.size), reshares_path(:root_guid => post.guid), :method => :post, :remote => true, :confirm => t('reshares.reshare.reshare_confirmation', :author => post.author.name)
    end
  end
end
