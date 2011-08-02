class AWS < Fog::Bin
  class << self

    def [](service)
      @@connections ||= Hash.new do |hash, key|
        hash[key] = case key
        when :cdn
          Fog::AWS::CDN.new
        when :compute
          Fog::AWS::Compute.new
        when :ec2
          location = caller.first
          warning = "[yellow][WARN] AWS[:ec2] is deprecated, use AWS[:compute] instead[/]"
          warning << " [light_black](" << location << ")[/] "
          Formatador.display_line(warning)
          Fog::AWS::Compute.new
        when :elb
          Fog::AWS::ELB.new
        when :eu_storage
          Fog::AWS::Storage.new(:region => 'eu-west-1')
        when :iam
          Fog::AWS::IAM.new
        when :sdb
          Fog::AWS::SimpleDB.new
        when :s3
          location = caller.first
          warning = "[yellow][WARN] AWS[:s3] is deprecated, use AWS[:storage] instead[/]"
          warning << " [light_black](" << location << ")[/] "
          Formatador.display_line(warning)
          Fog::AWS::Storage.new
        when :storage
          Fog::AWS::Storage.new
        end
      end
      @@connections[service]
    end

    def services
      [:cdn, :compute, :elb, :iam, :sdb, :storage]
    end

  end
end
