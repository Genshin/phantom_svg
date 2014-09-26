
module Phantom
  module SVG
    module Parser
      # Image reader.
      class AbstractImageReader
        attr_reader :frames, :width, :height, :loops, :skip_first, :has_animation
        alias_method :has_animation?, :has_animation

        # Construct AbstractImageReader object.
        def initialize(path = nil, options = {})
          read(path, options)
        end

        # Read image file from path.
        def read(path, options = {})
          raise 'Called abstract method.'
        end

        private

        # Reset SVGReader object.
        def reset
          @frames = []
          @width = nil
          @height = nil
          @loops = nil
          @skip_first = nil
          @has_animation = false
        end
      end # class AbstractImageReader
    end # module Parser
  end # module SVG
end # module Phantom
