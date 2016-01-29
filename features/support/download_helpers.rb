# Credits goes to Steve Richert
# http://collectiveidea.com/blog/archives/2012/01/27/testing-file-downloads-with-capybara-and-chromedriver/
module DownloadHelpers
  TIMEOUT ||= 5
  PATH ||= Rails.root.join("tmp/downloads")

  module_function

  def downloads
    Dir[PATH.join("*")]
  end

  def download
    wait_for_download
    downloads.first
  end

  def download_content
    wait_for_download
    File.read(download)
  end

  def wait_for_download
    Timeout.timeout(TIMEOUT) do
      sleep 0.1 until downloaded?
    end
  end

  def downloaded?
    !downloading? && downloads.any?
  end

  def downloading?
    downloads.grep(/\.part$/).any?
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
  end
end
