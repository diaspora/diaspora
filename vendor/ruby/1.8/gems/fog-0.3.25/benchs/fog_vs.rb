require 'rubygems'
require 'aws/s3'
require 'benchmark'
require 'right_aws'

require File.join(File.dirname(__FILE__), '..', 'lib', 'fog')

data = File.open(File.expand_path('~/.fog')).read
config = YAML.load(data)[:default]
fog = Fog::AWS::S3.new(
  :aws_access_key_id     => config[:aws_access_key_id],
  :aws_secret_access_key => config[:aws_secret_access_key]
)
raws = RightAws::S3Interface.new(
  config[:aws_access_key_id],
  config[:aws_secret_access_key]
)
raws.logger.level = 3 # ERROR
awss3 = AWS::S3::Base.establish_connection!(
  :access_key_id     => config[:aws_access_key_id],
  :secret_access_key => config[:aws_secret_access_key],
  :persistent        => true
)

TIMES = 10

Benchmark.bmbm(25) do |bench|
  bench.report('fog.put_bucket') do
    TIMES.times do |x|
      fog.put_bucket("fogbench#{x}")
    end
  end
  bench.report('raws.create_bucket') do
    TIMES.times do |x|
      raws.create_bucket("rawsbench#{x}")
    end
  end
  bench.report('awss3::Bucket.create') do
    TIMES.times do |x|
      AWS::S3::Bucket.create("awss3bench#{x}")
    end
  end

  bench.report('fog.put_object') do
    TIMES.times do |x|
      TIMES.times do |y|
        file = File.open(File.dirname(__FILE__) + '/../spec/lorem.txt', 'r')
        fog.put_object("fogbench#{x}", "lorem_#{y}", file)
      end
    end
  end
  bench.report('raws.put') do
    TIMES.times do |x|
      TIMES.times do |y|
        file = File.open(File.dirname(__FILE__) + '/../spec/lorem.txt', 'r')
        raws.put("rawsbench#{x}", "lorem_#{y}", file)
      end
    end
  end
  bench.report('awss3::S3Object.create') do
    TIMES.times do |x|
      TIMES.times do |y|
        file = File.open(File.dirname(__FILE__) + '/../spec/lorem.txt', 'r')
        AWS::S3::S3Object.create("lorem_#{y}", file, "awss3bench#{x}")
      end
    end
  end

  bench.report('fog.delete_object') do
    TIMES.times do |x|
      TIMES.times do |y|
        fog.delete_object("fogbench#{x}", "lorem_#{y}")
      end
    end
  end
  bench.report('raws.delete') do
    TIMES.times do |x|
      TIMES.times do |y|
        raws.delete("rawsbench#{x}", "lorem_#{y}")
      end
    end
  end
  bench.report('awss3::S3Object.delete') do
    TIMES.times do |x|
      TIMES.times do |y|
        AWS::S3::S3Object.delete("lorem_#{y}", "awss3bench#{x}")
      end
    end
  end

  bench.report('fog.delete_bucket') do
    TIMES.times do |x|
      fog.delete_bucket("fogbench#{x}")
    end
  end
  bench.report('raws.delete_bucket') do
    TIMES.times do |x|
      raws.delete_bucket("rawsbench#{x}")
    end
  end
  bench.report('awss3::Bucket.delete') do
    TIMES.times do |x|
      AWS::S3::Bucket.delete("awss3bench#{x}")
    end
  end
end
