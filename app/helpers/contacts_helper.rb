module ContactsHelper
  def contact_aspect_dropdown(contact)
    membership = contact.aspect_memberships.where(:aspect_id => @aspect.id).first unless @aspect.nil?

    if membership
      link_to(image_tag('icons/monotone_close_exit_delete.png', :height => 20, :width => 20),
        { :controller => "aspect_memberships",
          :action => 'destroy',
          :id => membership.id
        },
        :title => t('contacts.index.remove_person_from_aspect', :person_name => contact.person_first_name, :aspect_name => @aspect.name),
        :class => 'contact_remove-from-aspect',
        :method => 'delete',
        'data-membership_id' => membership.id
      )

    else
      render :partial => 'people/relationship_action',
              :locals => { :person => contact.person,
                           :contact => contact,
                           :current_user => current_user }
    end
  end

  def start_a_conversation_link(aspect, contacts_size)
    suggested_limit = 16
    conv_opts = { :class => "button conversation_button", :rel => "facebox"}
    conv_opts[:title] = t('.many_people_are_you_sure', :suggested_limit => suggested_limit) if contacts_size > suggested_limit
    link_to t('.start_a_conversation'), new_conversation_path(:aspect_id => aspect.id, :name => aspect.name), conv_opts
  end
end
