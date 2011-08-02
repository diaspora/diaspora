require 'mime/types'

module Typhoeus
  class Form
    attr_accessor :params
    attr_reader :traversal

    def initialize(params = {})
      @params = params
    end

    def traversal
      @traversal ||= Typhoeus::Utils.traverse_params_hash(params)
    end

    def process!
      # add params
      traversal[:params].each { |p| formadd_param(p[0], p[1]) }

      # add files
      traversal[:files].each { |file_args| formadd_file(*file_args) }
    end

    def multipart?
      !traversal[:files].empty?
    end

    def to_s
      Typhoeus::Utils.traversal_to_param_string(traversal, false)
    end
  end
end
