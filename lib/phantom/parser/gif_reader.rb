
require 'rexml/document'

require_relative '../frame.rb'
require_relative 'abstract_image_reader.rb'

module Phantom
  module SVG
    module Parser
      # GIF reader.
      class GIFReader < AbstractImageReader
        # Read gif file from path.
        def read(path, options = {})
          reset

          return if path.nil? || path.empty?
        end
      end # class GIFReader
    end # module Parser
  end # module SVG
end # module Phantom
