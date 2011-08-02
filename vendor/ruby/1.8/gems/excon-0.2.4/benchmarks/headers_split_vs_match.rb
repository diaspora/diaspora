# require 'benchmark'

# COUNT = 1_000_000
# data = "Content-Length: 100"
# Benchmark.bmbm(25) do |bench|
#   bench.report('regex') do
#     COUNT.times do
#       header = data.match(/(.*):\s(.*)/)
#     end
#   end
#   bench.report('split') do
#     COUNT.times do
#       header = data.split(': ')
#     end
#   end
# end

# Rehearsal ------------------------------------------------------------
# regex                      4.270000   0.010000   4.280000 (  4.294186)
# split                      3.870000   0.000000   3.870000 (  3.885645)
# --------------------------------------------------- total: 8.150000sec
# 
#                                user     system      total        real
# regex                      4.260000   0.010000   4.270000 (  4.284764)
# split                      3.860000   0.010000   3.870000 (  3.882795)

require 'rubygems'
require 'tach'

data = "Content-Length: 100"
Tach.meter(1_000_000) do
  tach('regex') do
    data.match(/(.*):\s(.*)/)
    header = [$1, $2]
  end
  tach('split') do
    header = data.split(': ')
  end
end

# +-------+----------+----------+
# | tach  | average  | total    |
# +-------+----------+----------+
# | regex | 4.680451 | 4.680451 |
# +-------+----------+----------+
# | split | 4.393218 | 4.393218 |
# +-------+----------+----------+
