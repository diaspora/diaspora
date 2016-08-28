require "yaml"

def environment_configuration
  @environment_configuration ||= YAML.load(open("#{File.dirname(__FILE__)}/config.yml"))["configuration"]
end

def pod_uri(pod_nr)
  environment_configuration["pod#{pod_nr}"]["uri"] || "http://pod#{pod_nr}.diaspora.local"
end

def pod_host(pod_nr)
  URI.parse(pod_uri(pod_nr)).host
end

def pod_count
  environment_configuration["pod_count"]
end
