JAVA_LIBS = {}

unless RUBY_VERSION == '1.8.6'
  # When we're building native windows gems with 1.8.6 this block of code fails.
  # We'll just disable running it - it's not needed at that stage of the build.
  
  require 'rexml/document'
  pom = REXML::Document.new(IO.read(File.dirname(__FILE__) + '/../../java/pom.xml'))
  pom_version = REXML::XPath.first(pom, '//xmlns:project/xmlns:version/text()').to_s
  REXML::XPath.each(pom, '//xmlns:project/xmlns:dependencies/xmlns:dependency').each do |dep|
    groupId = dep.get_elements('groupId')[0].text()
    artifactId = dep.get_elements('artifactId')[0].text()
    version = dep.get_elements('version')[0].text()
    scope = dep.get_elements('scope')[0].text() rescue nil

    jar = "~/.m2/repository/#{groupId.gsub(/\./, '/')}/#{artifactId}/#{version}/#{artifactId}-#{version}.jar"
    JAVA_LIBS["#{groupId}-#{artifactId}"] = jar if scope != 'test'
    require jar if defined?(JRUBY_VERSION)
  end
end