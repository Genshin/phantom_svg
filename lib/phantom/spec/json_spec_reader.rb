
require 'json'

require_relative '../svg/frame.rb'
require_relative 'abstract_spec_reader.rb'

module Phantom
  module Spec
    class JSONSpecReader < AbstractSpecReader
      private

      # Read parameter from spec file.
      def read_parameter(path)
        open(path) do |file|
          JSON.load(file).each do |key, val|
            case key
            when 'name'           then  set_name(val)
            when 'loops'          then  set_loops(val)
            when 'skip_first'     then  set_skip_first(val)
            when 'default_delay'  then  set_default_delay(val)
            when 'frames'         then  read_frame_infos(val)
            when 'delays'         then  val.each { |delay| add_delay(delay) }
            else                        # nop
            end
          end
        end
      end

      # Read frame informations
      def read_frame_infos(value)
        value.each do |frame_info|
          if frame_info.instance_of?(Hash)
            frame_info.each do |name, delay|
              add_frame_info(name, delay)
            end
          else
            add_frame_info(frame_info)
          end
        end
      end
    end # class JSONSpecReader < AbstractSpecReader
  end # module Spec
end # module Phantom
