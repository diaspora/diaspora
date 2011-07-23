module ResharesHelper
  def reshare_error_message(reshare)
    if @reshare.errors[:root_guid].present?
      escape_javascript(@reshare.errors[:root_guid].first)
    else
      escape_javascript(t('reshares.create.failure'))
    end
  end
end
