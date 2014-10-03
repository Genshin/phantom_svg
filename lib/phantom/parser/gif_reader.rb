require 'rexml/document'
require 'RMagick'
require 'rsvg2'

require_relative '../frame'
require_relative 'abstract_image_reader'

module Phantom
  module SVG
    module Parser
      # GIF reader.
      class GIFReader < AbstractImageReader
        include Magick
        # Read gif file from path.
        def read(path, options = {})
          reset

          return if path.nil? || path.empty?

          frames = create_frames(path)
          @frames += frames
          @width = "#{frames.first.width}px"
          @height = "#{frames.first.height}px"
        end

        private

        # Create frames for each frame in the gif.
        def create_frames(path, duration = nil)
          frames = []
          lst = ImageList.new path

          lst.each do |img|
            frame = Phantom::SVG::Frame.new
            frame.width = "#{img.columns}px"
            frame.height = "#{img.rows}px"
            frame.viewbox.set_from_text("0 0 #{img.columns} #{img.rows}")
            frame.surfaces = create_surfaces(path, img.columns, img.rows)
            frame.duration = img.delay * 10.0 unless img.delay.nil?
            frame.namespaces = {
              'xmlns' => 'http://www.w3.org/2000/svg',
              'xlink' => 'http://www.w3.org/1999/xlink'
            }
            frames << frame
          end
         frames
        end

        # Create surfaces.
        def create_surfaces(path, width, height)
          bin = File.binread(path)
          base64 = [bin].pack('m')

          image = REXML::Element.new('image')
          image.add_attributes(
            'width' => width,
            'height' => height,
            'xlink:href' => "data:image/gif;base64,#{base64}"
          )

          [image]
        end
      end # class GIFReader
    end # module Parser
  end # module SVG
end # module Phantom
