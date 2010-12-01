# encoding: utf-8
desc 'List contributors'
task :contributors do
  contributors = `git log --pretty=short --no-merges | git shortlog -ne | egrep -ve '^ +' | egrep -ve '^$'`.split("\n")
  puts contributors
  puts "Total: #{contributors.length}"
end

task :codeswarm do
  sh "code_swarm --reload" rescue nil # Fails because of encoding - which we'll fix
  sh "iconv -f latin1 -t utf-8 .git/.code_swarm/log.xml > tmp.xml && mv tmp.xml .git/.code_swarm/log.xml"
  sh "sed -e 's/Aslak\ Hellesøy@.BEKK.no/aslak.hellesoy@gmail.com/g' .git/.code_swarm/log.xml > tmp.xml && mv tmp.xml .git/.code_swarm/log.xml"
  sh "sed -e 's/josephwilk@joesniff.co.uk/joe@josephwilk.net/g' .git/.code_swarm/log.xml > tmp.xml && mv tmp.xml .git/.code_swarm/log.xml"
  sh "code_swarm"
end
