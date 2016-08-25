require 'rexml/document'
require 'rmagick'
require 'rsvg2'
require 'base64'

require_relative '../frame'
require_relative 'abstract_image_reader'

module Phantom
  module SVG
    module Parser
      # GIF reader.
      class GIFReader < AbstractImageReader
        include Magick
        # Read gif file from path.
        def read(path, _options = {})
          reset

          return if path.nil? || path.empty?

          frames = create_frames(path)
          @frames += frames
          @width = "#{frames.first.width}px"
          @height = "#{frames.first.height}px"
        end

        private

        # Create frames for each frame in the gif.
        def create_frames(path, _duration = nil)
          frames = []
          lst = ImageList.new path

          lst.each do |img|
            frame = set_param(img)
            frames << frame
          end
          frames
        end

        def set_param(img)
          frame = Phantom::SVG::Frame.new
          frame.width = "#{img.columns}px"
          frame.height = "#{img.rows}px"
          frame.viewbox.set_from_text("0 0 #{img.columns} #{img.rows}")
          frame.surfaces = create_surfaces(img)
          frame.duration = img.delay * 0.01 unless img.delay.nil?
          frame.namespaces = { 'xmlns' => 'http://www.w3.org/2000/svg',
                               'xlink' => 'http://www.w3.org/1999/xlink' }
          frame
        end

        # Create surfaces.
        def create_surfaces(img)
          img.format = 'PNG'
          base64 = Base64.encode64(img.to_blob)

          image = REXML::Element.new('image')
          image.add_attributes(
            'width' => img.columns,
            'height' => img.rows,
            'xlink:href' => "data:image/png;base64,#{base64}"
          )

          [image]
        end
      end # class GIFReader
    end # module Parser
  end # module SVG
end # module Phantom
