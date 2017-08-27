# frozen_string_literal: true

if defined? Cucumber

namespace :screenshots do

  Cucumber::Rake::Task.new({:reference => 'db:test:prepare'}, 'Take reference screenshots') do |t|
    t.profile = 'ref_screens'
  end

  Cucumber::Rake::Task.new({:comparison => 'db:test:prepare'}, 'Take comparison screenshots') do |t|
    t.profile = 'cmp_screens'
  end

  desc 'Take reference and comparison screenshots'
  task :all => [:reference, :comparison]

  desc 'Generate "flicker" images for easy comparison (requires RMagick)'
  task :flicker do
    screen_dir = Rails.root.join('tmp', 'screenshots')

    ref_dir = screen_dir.join('reference')
    cur_dir = screen_dir.join('current')

    Dir.glob("#{ref_dir}/*.png") do |img|
      filename = File.basename(img)

      if !File.exist?(cur_dir.join(filename))
        raise "the comparison screenshot for #{filename} doesn't exist!"
      end

      MiniMagick::Tool::Convert.new do |convert|
        convert.merge! ["-delay", "65", "-loop", "0"]
        convert << ref_dir.join(filename)
        convert << cur_dir.join(filename)
        convert << screen_dir.join("#{filename}.gif")
      end
    end

    puts %Q(
    Done!
    You can find the flicker images here:

      #{screen_dir}

    )
  end
end

end
