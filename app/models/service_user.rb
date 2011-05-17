class ServiceUser < ActiveRecord::Base

  belongs_to :person
  belongs_to :contact
  belongs_to :service
  belongs_to :request
  belongs_to :invitation

  before_save :attach_local_models

  private
  def attach_local_models
    service_for_uid = Services::Facebook.where(:type => service.type.to_s, :uid => self.uid).first
    if !service_for_uid.blank? && (service_for_uid.user.person.profile.searchable)
      self.person = service_for_uid.user.person
    else
      self.person = nil
    end

    if self.person
      self.contact = self.service.user.contact_for(self.person)
      self.request = Request.where(:recipient_id => self.service.user.person.id,
                                   :sender_id => self.person_id).first
    end

    self.invitation = Invitation.joins(:recipient).where(:sender_id => self.service.user_id,
                                                            :users => {:invitation_service => self.service.provider,
                                                                       :invitation_identifier => self.uid}).first
  end
end

class FakeServiceUser < HashWithIndifferentAccess
  def initialize(row)
    columns = ServiceUser.column_names
    self.replace Hash[columns.zip(row)]
  end

  ServiceUser.column_names.each do |column|
    symbol = column.to_sym
    define_method symbol do
      self[symbol]
    end
  end

  ServiceUser.reflect_on_all_associations.each do |assoc|
    define_method assoc.name do
      if associated_id = self[assoc.primary_key_name]
        assoc.klass.unscoped.find(associated_id)
      else
        nil
      end
    end
  end
end

