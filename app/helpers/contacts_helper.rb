module ContactsHelper
  def contact_aspect_dropdown(contact)
    if @aspect
      link_to(image_tag('icons/monotone_close_exit_delete.png', :height => 20, :width => 20),
      {:controller => "aspect_memberships",
        :action => 'destroy',
         :id => 42,
         :aspect_id => @aspect.id,
         :person_id => contact.person_id
        },
        :title => t('.remove_person_from_aspect', :person_name => contact.person_first_name, :aspect_name => @aspect.name),
            :method => 'delete')

    else
      render :partial => 'people/relationship_action',
              :locals => { :person => contact.person, :contact => contact,
                            :current_user => current_user }
    end
  end
end
