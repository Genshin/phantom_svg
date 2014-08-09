require 'rapngasm'
require 'rsvg2'
require 'tmpdir'
require 'cairo'

require_relative '../frame.rb'

module Phantom
  module SVG
    module Parser
      module Raster
        def load_raster(path, id)
          apngasm = APNGAsm.new
          apngasm.disassemble(path)

          if apngasm.frame_count == 1 
            @frames << create_frame_from_png(path, id)
          else
            create_frame_from_apng(apngasm, id)
          end

          apngasm.reset
        end

        def create_frame_from_png(path, id, duration = nil)
          pixbuf = Gdk::Pixbuf.new(path)

          frame = Phantom::SVG::Frame.new
          frame.width = "#{pixbuf.width}px"
          frame.height = "#{pixbuf.height}px"
          frame.surfaces = create_surfaces(path, pixbuf.width, pixbuf.height)
          frame.duration = duration unless duration.nil?
          frame.namespaces = {
            'xmlns' => 'http://www.w3.org/2000/svg',
            'xlink' => 'http://www.w3.org/1999/xlink'
          }

          frame
        end

        def create_frame_from_apng(apngasm, id)
          png_frames = apngasm.get_frames
          width = 0
          height = 0
          Dir::mktmpdir(nil, File.dirname(__FILE__)) do |dir|
            apngasm.save_pngs(dir)
            png_frames.each_with_index do |png_frame, i|
              width = png_frame.width if width < png_frame.width
              height = png_frame.height if height < png_frame.height
              duration = png_frame.delay_numerator.to_f / png_frame.delay_denominator.to_f
              @frames << create_frame_from_png("#{dir}/#{i}.png", id, duration)
            end
          end
          @width = "#{width}px"
          @height = "#{height}px"
          @loops = apngasm.get_loops
          @skip_first = apngasm.is_skip_first
        end

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

        def save_rasterized(path)
          set_size if @width.to_i == 0 || @height.to_i == 0

          apngasm = APNGAsm.new
          apngasm.set_loops(@loops)
          apngasm.set_skip_first(@skip_first)

          Dir::mktmpdir(nil, File.dirname(__FILE__)) do |dir|
            @frames.each_with_index do |frame, i|
              create_tmp_file("#{dir}/tmp#{i}", frame)
              apngasm.add_frame_file("#{dir}/tmp#{i}.png", frame.duration.to_f * 1000, 1000)
            end
          end

          result = apngasm.assemble(path)
          apngasm.reset

          result
        end

        def create_tmp_file(path, frame)
          save_svg_frame("#{path}.svg", frame, @width, @height)
          convert_to_png(path, frame)
        end

        def convert_to_png(path, frame)
          handle = RSVG::Handle.new_from_file("#{path}.svg")

          surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, @width, @height)
          context = Cairo::Context.new(surface)
          context.scale(@width / handle.dimensions.width, @height / handle.dimensions.height)
          context.render_rsvg_handle(handle)

          surface.write_to_png("#{path}.png")
          surface.finish
        end
      end
    end
  end
end
