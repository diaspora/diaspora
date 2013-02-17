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
    require 'RMagick'
    screen_dir = Rails.root.join('tmp', 'screenshots')

    ref_dir = screen_dir.join('reference')
    cur_dir = screen_dir.join('current')

    Dir.glob("#{ref_dir}/*.png") do |img|
      filename = File.basename(img)

      if !File.exist?(cur_dir.join(filename))
        raise "the comparison screenshot for #{filename} doesn't exist!"
      end

      img_list = Magick::ImageList.new(ref_dir.join(filename), cur_dir.join(filename))
      img_list.delay = 65      # number of ticks between flicker img change (100 ticks/second)
      img_list.iterations = 0  # -> endless loop
      img_list.write(screen_dir.join("#{filename}.gif"))
    end

    puts %Q(
    Done!
    You can find the flicker images here:

      #{screen_dir}

    )
  end
end

end
