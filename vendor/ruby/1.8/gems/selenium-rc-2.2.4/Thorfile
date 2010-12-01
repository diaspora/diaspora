require "zip/zip"

class Joe < Thor
  desc "build", "builds the selenium-rc gem"
  def build
    fetch_jar
  end

  def fetch_jar
    url = "http://selenium.googlecode.com/files/selenium-server-standalone-2.0a4.jar"
    file = File.join("tmp", File.basename(url))

    FileUtils.mkdir_p("tmp")

    system "wget #{url} -O #{file}" unless File.exist?(file)

    FileUtils.mv("#{file}", "vendor/selenium-server.jar")
  end
end
