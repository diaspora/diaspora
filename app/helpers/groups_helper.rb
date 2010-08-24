module GroupsHelper
  def link_for_group( group )
    puts request.params
    link_to group.name, group
  end
end
