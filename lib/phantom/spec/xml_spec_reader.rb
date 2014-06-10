
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
        unless animation.nil?
          animation.attributes.each do |key, val|
            case key
            when 'name'           then  set_name(val)
            when 'loops'          then  set_loops(val)
            when 'skip_first'     then  set_skip_first(val)
            when 'default_delay'  then  set_default_delay(val)
            else                        # nop
            end
          end
          animation.elements.each('frame') do |element|
            add_frame_info(element.attributes['src'], element.attributes['delay'])
          end
        end
      end
    end # class XMLSpecReader < AbstractSpecReader
  end # module Spec
end # module Phantom
