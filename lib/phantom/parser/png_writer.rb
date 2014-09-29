
require 'tmpdir'
require 'rapngasm'
require 'cairo'

require_relative 'svg_writer.rb'
require_relative 'abstract_image_writer.rb'

module Phantom
  module SVG
    module Parser
      # Image writer.
      class PNGWriter < AbstractImageWriter
        # Write png file from object to path.
        # Return write size.
        def write(path, object)
          return 0 if path.nil? || path.empty? || object.nil?

          object.set_size

          apngasm = APNGAsm.new
          convert_frames(apngasm, object)
          result = apngasm.assemble(path)

          result
        end

        private

        def convert_frames(apngasm, object)
          apngasm.set_loops(object.loops)
          apngasm.set_skip_first(object.skip_first)

          Dir.mktmpdir(nil, File.dirname(__FILE__)) do |dir|
            object.frames.each_with_index do |frame, index|
              tmp_file_path = "#{dir}/tmp#{index}"
              create_temporary_file(tmp_file_path, frame)
              apngasm.add_frame_file("#{tmp_file_path}.png", frame.duration.to_f * 1000, 1000)
            end
          end
        end

        def create_temporary_file(path, frame)
          Parser::SVGWriter.new.write("#{path}.svg", frame)

          handle = RSVG::Handle.new_from_file("#{path}.svg")
          w = frame.width.to_i
          h = frame.height.to_i
          surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, w, h)
          context = Cairo::Context.new(surface)
          context.scale(w / handle.dimensions.width, h / handle.dimensions.height)
          context.render_rsvg_handle(handle)
          surface.write_to_png("#{path}.png")
          surface.finish
        end
      end # class PNGWriter
    end # module Parser
  end # module SVG
end # module Phantom
