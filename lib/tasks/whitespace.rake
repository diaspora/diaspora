namespace :whitespace do
  desc 'Removes trailing whitespace'
  task :cleanup do
    sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
  end
  desc 'Converts hard-tabs into two-space soft-tabs'
  task :retab do
    sh %{find . -name '*.rb' -exec sed -i '' 's/\t/  /g' {} \\;}
  end
  desc 'Remove consecutive blank lines'
  task :scrub_gratuitous_newlines do
    sh %{find . -name '*.rb' -exec sed -i '' '/./,/^$/!d' {} \\;}
  end
end

