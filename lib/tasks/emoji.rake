namespace :emoji do

	desc 'Refresh Emoji images and scripts'
	task :refresh do
		require 'nokogiri'
		require 'open-uri'


		data = Nokogiri::HTML(open("https://github.com/arvida/emoji-cheat-sheet.com/tree/master/public/graphics/emojis"))
	  	# Loop over all available images, and download them in the public/images/emoji directory
	  	data.css(".js-directory-link").each do |link|

	  		if File.file?("#{Rails.root}/app/assets/images/emoji/#{link.text}")
	  			puts "The file #{link.text} exists, so skipping download...." 
	  		else
	  			puts "Downloading #{link.text} and storing it in #{Rails.root}/app/assets/images/emoji/"

	  			open("https://raw.github.com/arvida/emoji-cheat-sheet.com/master/public/graphics/emojis/#{link.text}") { |f|
	  				File.open("#{Rails.root}/app/assets/images/emoji/#{link.text}","wb") do |file|
	  					file.puts f.read
	  				end
	  			}


	  		end
	  	end

	  	# Updates the Emojify script from https://github.com/hassankhan/emojify.js in the app/assets/javascript directory
	  	data = open("https://raw.github.com/hassankhan/emojify.js/master/emojify.js")
	  	puts "Updating emojify.js from https://github.com/hassankhan/emojify.js and saving it in #{Rails.root}/app/assets/javascript/emojify.js "
	  	File.open("#{Rails.root}/app/assets/javascripts/emojify.js","wb") do |file|
	  		file.puts data.read
	  	end
	  	puts "Updated Emoji files"
	end
end

