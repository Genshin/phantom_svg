
require 'json'

module Phantom
  module Spec
    class JsonSpecReader
      def read(path)
        open(path) do |file|
          JSON.load(file).each do |key, val|
            case key
            when "name"           then # nop
            when "loops"          then # nop
            when "skip_first"     then # nop
            when "default_delay"  then # nop
            when "frames"         then # nop
            when "delays"         then # nop
            else
              # nop
            end
          end
        end


      end
    end # class JsonSpecReader
  end # module Spec
end # module Phantom
