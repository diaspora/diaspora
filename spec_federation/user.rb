class User
  attr_accessor :pod_id

  def initialize(pod_id)
    self.pod_id = pod_id
  end

  def api_client
    @client ||= DiasporaApi::InternalApi.new(pod_uri(pod_id))
  end

  delegate :diaspora_id, to: :api_client

  def register
    api_client.register("test#{r_str}@test.local", "test#{r_str}", "123456")
  end

  def remote_person(diaspora_id)
    people = api_client.find_or_fetch_person(diaspora_id)
    return unless people
    people.first
  end

  def add_to_first_aspect(remote_user)
    person = remote_person(remote_user.diaspora_id)
    return unless person

    api_client.add_to_aspect(
      person["id"],
      api_client.aspects.first["id"]
    )
  end

  def wait_for_notification(type, timeout=20)
    notifications = nil
    timeout.times do
      notifications = api_client.notifications
      if notifications
        notifications.select! do |notification|
          notification[type]
        end
        break if notifications.count > 0
      end
      sleep(1)
    end

    notifications
  end
end
