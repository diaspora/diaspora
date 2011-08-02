require 'fog/core/collection'
require 'fog/aws/models/compute/flavor'

module Fog
  module AWS
    class Compute

      class Flavors < Fog::Collection

        model Fog::AWS::Compute::Flavor

        def all
          data = [
            { :bits => 0,  :cores =>   2,  :disk => 0,    :id =>  't1.micro',   :name => 'Micro Instance',       :ram => 613},

            { :bits => 32, :cores =>   1,  :disk => 160,  :id =>  'm1.small',   :name => 'Small Instance',       :ram => 1740.8},
            { :bits => 64, :cores =>   4,  :disk => 850,  :id =>  'm1.large',   :name => 'Large Instance',       :ram => 7680},
            { :bits => 64, :cores =>   8,  :disk => 1690, :id =>  'm1.xlarge',  :name => 'Extra Large Instance', :ram => 15360},

            { :bits => 32, :cores =>   5,  :disk => 350,  :id =>  'c1.medium',  :name => 'High-CPU Medium',      :ram => 1740.8},
            { :bits => 64, :cores =>  20,  :disk => 1690, :id =>  'c1.xlarge',  :name => 'High-CPU Extra Large', :ram => 7168},

            { :bits => 64, :cores =>  6.5, :disk => 420,  :id =>  'm2.xlarge',  :name => 'High-Memory Extra Large',           :ram => 17510.4},
            { :bits => 64, :cores =>   13, :disk => 850,  :id =>  'm2.2xlarge', :name => 'High Memory Double Extra Large',    :ram => 35020.8},
            { :bits => 64, :cores =>   26, :disk => 1690, :id =>  'm2.4xlarge', :name => 'High Memory Quadruple Extra Large', :ram => 70041.6},

            { :bits => 64, :cores => 33.5, :disk => 1690, :id => 'cc1.4xlarge', :name => 'Cluster Compute Quadruple Extra Large', :ram => 23552},
            { :bits => 64, :cores => 33.5, :disk => 1690, :id => 'cg1.4xlarge', :name => 'Cluster GPU Quadruple Extra Large',     :ram => 22528}
          ]
          load(data)
          self
        end

        def get(flavor_id)
          self.class.new(:connection => connection).all.detect {|flavor| flavor.id == flavor_id}
        end

      end

    end
  end
end
