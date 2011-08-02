# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{aws}
  s.version = "2.3.32"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Travis Reeder", "Chad Arimura", "RightScale"]
  s.date = %q{2010-12-19}
  s.description = %q{AWS Ruby Library for interfacing with Amazon Web Services.}
  s.email = %q{travis@appoxy.com}
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["lib/acf/right_acf_interface.rb", "lib/aws.rb", "lib/awsbase/aws_response_array.rb", "lib/awsbase/benchmark_fix.rb", "lib/awsbase/right_awsbase.rb", "lib/awsbase/support.rb", "lib/ec2/right_ec2.rb", "lib/ec2/right_mon_interface.rb", "lib/elb/elb_interface.rb", "lib/iam/iam.rb", "lib/rds/rds.rb", "lib/right_aws.rb", "lib/s3/right_s3.rb", "lib/s3/right_s3_interface.rb", "lib/sdb/active_sdb.rb", "lib/sdb/right_sdb_interface.rb", "lib/sqs/right_sqs.rb", "lib/sqs/right_sqs_interface.rb", "README.markdown", "test/acf/test_acf.rb", "test/acf/test_helper.rb", "test/ec2/test_ec2.rb", "test/ec2/test_helper.rb", "test/ec2/test_mon.rb", "test/elb/test_elb.rb", "test/http_connection.rb", "test/iam/test_iam.rb", "test/rds/test_rds.rb", "test/s3/test_helper.rb", "test/s3/test_s3.rb", "test/s3/test_s3_stubbed.rb", "test/sdb/test_active_sdb.rb", "test/sdb/test_helper.rb", "test/sdb/test_sdb.rb", "test/sqs/test_helper.rb", "test/sqs/test_sqs.rb", "test/test_credentials.rb", "test/ts_right_aws.rb"]
  s.homepage = %q{http://github.com/appoxy/aws/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{AWS Ruby Library for interfacing with Amazon Web Services.}
  s.test_files = ["test/acf/test_acf.rb", "test/acf/test_helper.rb", "test/ec2/test_ec2.rb", "test/ec2/test_helper.rb", "test/ec2/test_mon.rb", "test/elb/test_elb.rb", "test/http_connection.rb", "test/iam/test_iam.rb", "test/rds/test_rds.rb", "test/s3/test_helper.rb", "test/s3/test_s3.rb", "test/s3/test_s3_stubbed.rb", "test/sdb/test_active_sdb.rb", "test/sdb/test_helper.rb", "test/sdb/test_sdb.rb", "test/sqs/test_helper.rb", "test/sqs/test_sqs.rb", "test/test_credentials.rb", "test/ts_right_aws.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<uuidtools>, [">= 0"])
      s.add_runtime_dependency(%q<http_connection>, [">= 0"])
      s.add_runtime_dependency(%q<xml-simple>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
    else
      s.add_dependency(%q<uuidtools>, [">= 0"])
      s.add_dependency(%q<http_connection>, [">= 0"])
      s.add_dependency(%q<xml-simple>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
    end
  else
    s.add_dependency(%q<uuidtools>, [">= 0"])
    s.add_dependency(%q<http_connection>, [">= 0"])
    s.add_dependency(%q<xml-simple>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
  end
end
