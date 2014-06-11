
require 'rexml/document'

require_relative '../svg/frame.rb'
require_relative 'abstract_animation_reader.rb'

module Phantom
  module Reader
    class XMLAnimationReader < AbstractAnimationReader
      private

      # Read parameter from animation information file.
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
    end # class XMLAnimationReader < AbstractAnimationReader
  end # module Reader
end # module Phantom
