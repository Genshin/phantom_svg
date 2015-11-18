
require 'tmpdir'
require 'RAPNGAsm'
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

          apngasm = APNGAsm::APNGAsm.new
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
              create_temporary_file(tmp_file_path, frame, object.width.to_i, object.height.to_i)
              apngasm.add_frame_file("#{tmp_file_path}.png", (frame.duration.to_f * 1000).to_i, 1000)
            end
          end
        end

        def create_temporary_file(path, frame, width, height)
          Parser::SVGWriter.new.write("#{path}.svg", frame)

          handle = RSVG::Handle.new
          File.open("#{path}.svg", "rb") do |file|
            buffer = ""
            while file.read(8192, buffer)
              handle.write(buffer)
            end
          end
          handle.close
          Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, width, height) do |surface|
            Cairo::Context.new(surface) do |context|
              context.scale(width.to_f / handle.dimensions.width,
                            height.to_f / handle.dimensions.height)
              context.render_rsvg_handle(handle)
              surface.write_to_png("#{path}.png")
              surface.finish
            end
          end
        end
      end # class PNGWriter
    end # module Parser
  end # module SVG
end # module Phantom
