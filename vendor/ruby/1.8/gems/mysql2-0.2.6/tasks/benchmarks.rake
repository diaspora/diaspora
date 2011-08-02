namespace :bench do
  [ :active_record, :escape, :query_with_mysql_casting,
    :query_without_mysql_casting, :sequel, :allocations,
    :thread_alone].each do |feature|
      desc "Run #{feature} benchmarks"
      task(feature){ ruby "benchmark/#{feature}.rb" }
  end
end