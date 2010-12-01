if defined?(JRUBY_VERSION)
  require 'rexml/document'
  pom = REXML::Document.new(IO.read(File.dirname(__FILE__) + '/../../java/pom.xml'))
  pom_version = REXML::XPath.first(pom, '//xmlns:project/xmlns:version/text()').to_s
  REXML::XPath.each(pom, '//xmlns:project/xmlns:dependencies/xmlns:dependency').each do |dep|
    groupId = dep.get_elements('groupId')[0].text()
    artifactId = dep.get_elements('artifactId')[0].text()
    version = dep.get_elements('version')[0].text()

    jar = "~/.m2/repository/#{groupId.gsub(/\./, '/')}/#{artifactId}/#{version}/#{artifactId}-#{version}.jar"
    require jar
  end
end