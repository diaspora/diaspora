module AspectsHelper
  def link_for_aspect( aspect )
    link_to aspect.name, aspect
  end
end
