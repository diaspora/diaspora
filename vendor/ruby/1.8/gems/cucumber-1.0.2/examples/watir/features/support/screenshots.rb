# This is an example of how you can set up screenshots for your
# browser testing. Just run cucumber with --format html --out report.html
#
# The code below will work on OS X or Windows (with IE Watir only).
# Adding support for other platforms should be easy - as long as there is a 
# ruby library or command line tool to take pictures.
#
module Screenshots
  if Cucumber::OS_X
    def embed_screenshot(id)
      `screencapture -t png #{id}.png`
      embed("#{id}.png", "image/png")
    end
  elsif Cucumber::WINDOWS
    # http://wtr.rubyforge.org/rdoc/classes/Watir/ScreenCapture.html
    require 'watir/screen_capture'
    include Watir::ScreenCapture
    def embed_screenshot(id)
      screen_capture("#{id}.jpg", true)
      embed("#{id}.jpg", "image/jpeg")
    end
  else
    # Other platforms...
    def embed_screenshot(id)
      STDERR.puts "Sorry - no screenshots on your platform yet."
    end
  end
end
World(Screenshots)

After do
  embed_screenshot("screenshot-#{Time.new.to_i}")
end

# Other variants:
#
# Only take screenshot on failures
#
#   After do |scenario|
#     embed_screenshot("screenshot-#{Time.new.to_i}") if scenario.failed?
#   end
#
# Only take screenshot for scenarios or features tagged @screenshot
#
#   After(@screenshot) do
#     embed_screenshot("screenshot-#{Time.new.to_i}")
#   end
