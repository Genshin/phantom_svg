require 'rapngasm'
require 'rsvg2'
require 'tmpdir'
require 'rexml/document'

require_relative '../frame.rb'
require_relative 'abstract_image_reader.rb'

module Phantom
  module SVG
    module Parser
      # PNG reader.
      class PNGReader < AbstractImageReader
        # Read png file from path.
        def read(path, _options = {})
          reset

          return if path.nil? || path.empty?

          apngasm = APNG::APNGAsm.new
          apngasm.disassemble(path)

          if apngasm.frame_count == 1
            read_png(path)
          else
            read_apng(apngasm)
          end
        end

        private

        def read_png(path)
          frame = create_frame(path)
          @frames << frame
          @width = "#{frame.width}px"
          @height = "#{frame.height}px"
        end

        def read_apng(apngasm)
          @width = @height = 0
          Dir.mktmpdir(nil, File.dirname(__FILE__)) do |dir|
            set_frame(apngasm, dir)
          end

          @width = "#{@width}px"
          @height = "#{@height}px"
          @loops = apngasm.get_loops
          @skip_first = apngasm.is_skip_first
          @has_animation = true
        end

        def set_frame(apngasm, dir)
          # Create temporary file.
          apngasm.save_pngs(dir)

          # Create frames.
          apngasm.get_frames.each_with_index do |png_frame, index|
            @width = png_frame.width if @width < png_frame.width
            @height = png_frame.height if @height < png_frame.height
            duration = png_frame.delay_numerator.to_f / png_frame.delay_denominator.to_f
            @frames << create_frame("#{dir}/#{index}.png", duration)
          end
        end

        # Create frame.
        def create_frame(path, duration = nil)
          pixbuf = Gdk::Pixbuf.new(file: path)
          frame = set_param(path, pixbuf, duration)

          frame
        end

        def set_param(path, pixbuf, duration)
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
            'xlink:href' => "data:image/png;base64,#{base64}"
          )

          [image]
        end
      end # class PNGReader
    end # Parser
  end # SVG
end # Phantom
