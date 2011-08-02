desc "Run flog over significant files"
task :flog do
  sh "find lib/cucumber -name \\*.rb | grep -v parser\/feature\\.rb | xargs flog"
end