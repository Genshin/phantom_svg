require 'rsvg2'
require 'rexml/document'

require_relative '../frame'
require_relative 'abstract_image_reader'

module Phantom
  module SVG
    module Parser
      # JPEG reader.
      class JPEGReader < AbstractImageReader
        # Read jpeg file from path.
        def read(path, _options = {})
          reset

          return if path.nil? || path.empty?

          frame = create_frame(path)
          @frames << frame
          @width = "#{frame.width}"
          @height = "#{frame.height}"
        end

        private

        # Create frame.
        def create_frame(path, duration = nil)
          pixbuf = GdkPixbuf::Pixbuf.new(file: path)

          frame = Phantom::SVG::Frame.new
          frame.width = "#{pixbuf.width}px"
          frame.height = "#{pixbuf.height}px"
          frame.viewbox.set_from_text("0 0 #{pixbuf.width} #{pixbuf.height}")
          frame.surfaces = create_surfaces(path, pixbuf.width, pixbuf.height)
          frame.duration = duration unless duration.nil?
          frame.namespaces = { 'xmlns' => 'http://www.w3.org/2000/svg',
                               'xlink' => 'http://www.w3.org/1999/xlink' }
          frame
        end

        # Create surfaces.
        def create_surfaces(path, width, height)
          bin = File.binread(path)
          base64 = [bin].pack('m')

          image = REXML::Element.new('image')
          image.add_attributes(
            'width' => width,
            'height' => height,
            'xlink:href' => "data:image/jpeg;base64,#{base64}"
          )

          [image]
        end
      end # class JPEGReader
    end # module Parser
  end # module SVG
end # module Phantom
