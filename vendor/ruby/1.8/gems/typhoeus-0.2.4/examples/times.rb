require File.dirname(__FILE__) + '/../lib/typhoeus.rb'

hydra = Typhoeus::Hydra.new
hydra.disable_memoization

urls = [
    'http://google.com',
    'http://testphp.vulnweb.com',
    'http://demo.testfire.net',
    'http://example.net',
]

10.times {
    |i|

    req = Typhoeus::Request.new( urls[ i % urls.size] )
    req.on_complete {
        |res|
        puts 'URL:     ' + res.effective_url
        puts 'Time:    ' + res.time.to_s
        puts 'Connect time: ' + res.connect_time.to_s
        puts 'App connect time:    ' + res.app_connect_time.to_s
        puts 'Start transfer time: ' + res.start_transfer_time.to_s
        puts 'Pre transfer time:   ' + res.pretransfer_time.to_s
        puts '-------------'
    }

    hydra.queue( req )
    puts 'Queued: ' + req.url
}

puts
puts 'Harvesting responses...'
puts

hydra.run

puts
puts 'Done.'
puts