
require 'rexml/document'

require_relative '../svg/frame.rb'
require_relative 'abstract_spec_reader.rb'

module Phantom
  module Spec
    class XMLSpecReader < AbstractSpecReader
      private

      # Read parameter from spec file.
      def read_parameter(path)
        xml = REXML::Document.new(open(path))

        animation = xml.elements['animation']
        return if animation.nil?

        animation.attributes.each do |key, val|
          set_parameter(key, val)
        end

        animation.elements.each('frame') do |element|
          add_frame_info(element.attributes['src'], element.attributes['delay'])
        end
      end
    end # class XMLSpecReader < AbstractSpecReader
  end # module Spec
end # module Phantom
