class Curl
  def self.post(s)
    `curl -X POST -d #{s}`;;
  end
  
  def self.get(s)
    `curl -X GET #{s}`
  end
end

