# frozen_string_literal: true

module NotificationMailers
  class ContactsBirthday < NotificationMailers::Base
    attr_accessor :person

    def set_headers(person_id)
      @person = Person.find(person_id)
      @headers[:subject] = I18n.t("notifier.contacts_birthday.subject", name: @person.name)
    end
  end
end
