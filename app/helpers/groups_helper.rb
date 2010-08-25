module GroupsHelper
  def link_for_group( group )
    link_to group.name, group
  end
end
