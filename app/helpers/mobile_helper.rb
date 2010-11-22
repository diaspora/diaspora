module MobileHelper
  def aspect_select_options(aspects, selected)
    selected_id = selected == :all ? "" : selected.id
    '<option value="" >All</option>\n'.html_safe + options_from_collection_for_select(aspects, "id", "name", selected_id)
  end
end