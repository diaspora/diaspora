class Pod < ActiveRecord::Base
  def self.find_or_create_by_url(url)
    u = URI.parse(url)
    pod = self.find_or_initialize_by_host(u.host)
    unless pod.persisted?
      pod.ssl = (u.scheme == 'https')? true : false
      pod.save
    end
    pod
  end
end
