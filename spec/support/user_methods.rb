class User
  def send_contact_request_to(desired_contact, aspect)
    fantasy_resque do
      contact = Contact.new(:person => desired_contact,
                            :user => self,
                            :pending => true)
      contact.aspects << aspect

      if contact.save!
        contact.dispatch_request
      else
        nil
      end
    end
  end

  def post(class_name, opts = {})
    fantasy_resque do
      p = build_post(class_name, opts)
      if p.save!
        raise 'MongoMapper failed to catch a failed save' unless p.id

        self.aspects.reload
        
        aspects = self.aspects_from_ids(opts[:to])
        add_to_streams(p, aspects)
        dispatch_post(p, :to => opts[:to])
      end
      p
    end
  end

  def comment(text, options = {})
    fantasy_resque do
      c = build_comment(text, options)
      if c.save!
        raise 'MongoMapper failed to catch a failed save' unless c.id
        dispatch_comment(c)
      end
      c
    end
  end
end
