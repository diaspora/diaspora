namespace :whitespace do
  desc 'Removes trailing whitespace'
  task :cleanup do
    sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
  end
  desc 'Converts hard-tabs into two-space soft-tabs'
  task :retab do
    sh %{find . -name '*.rb' -exec sed -i '' 's/\t/  /g' {} \\;}
  end
end

