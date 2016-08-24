module Phantom
  module SVG
    module Parser
      # Image writer.
      class AbstractImageWriter
        # Construct AbstractImageWriter object.
        def initialize(path = nil, object = nil)
          write(path, object)
        end

        # Write image file from object to path.
        # Return write size.
        def write(_path, _object)
          fail 'Called abstract method.'
        end
      end # class AbstractImageWriter
    end # module Parser
  end # module SVG
end # module Phantom
