module Cucumber
  module Ast
    module Names
      attr_reader :title, :description
      
      def name
        s = @title
        s += "\n#{@description}" if @description != ""
        s
      end
    end
  end
end