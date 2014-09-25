
module Phantom
  module SVG
    module Parser
      # Image reader.
      class AbstractImageReader
        attr_reader :frames, :width, :height, :loops, :skip_first, :has_animation
        alias_method :has_animation?, :has_animation
      end # class AbstractImageReader
    end # module Parser
  end # module SVG
end # module Phantom
