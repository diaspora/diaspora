namespace :oembed do

  desc "Fix cached oembed objects to stop them from overlapping on the top bar"
  task :update => :environment do
    print "Fetching cached oembed responses that need fixing..."
    caches = OEmbedCache.where('url LIKE :youtube OR url LIKE :soundcloud',
                                { :youtube => "%youtube.com%",
                                  :soundcloud => "%soundcloud.com%" })
    puts "DONE. #{caches.length} records fetched."

    # only leave those that haven't had the wmode fix applied
    caches.delete_if {|c| c.data['html'].include? 'wmode'}
    if caches.empty?
      puts "Nothing to do."
      next
    end

    # run fix
    print "Fixing #{caches.length} cached oembed responses..."
    caches.each {|c| c.fix_embed_code; c.save}
    puts "DONE!"
  end

end
