require 'rapngasm'
require 'gdk3'
require 'rsvg2'
require_relative 'svg/frame.rb'

module Phantom
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
      # handle = RSVG::Handle.new_from_file(path)

      # antom::SVG::Frame.new
      # frame.path = path
      # frame.width = handle.dimentions.width
      # frame.height = handle.dimentions.height
      # frame.surface = get_base64(path, id)
      # frame.duration = duration unless duration.nil?

      pixbuf = Gdk::Pixbuf.new(path)

      frame = Phantom::SVG::Frame.new
      frame.path = path
      frame.width = pixbuf.width
      frame.height = pixbuf.height
      frame.surface = get_base64(path, id, pixbuf.width, pixbuf.height)
      frame.duration = duration unless duration.nil?

      frame
    end

    def create_frame_from_apng(apngasm, id)
      png_frames = apngasm.get_frames
      Dir::mktmpdir(nil, File.dirname(__FILE__)) do |dir|
        apngasm.save_pngs(dir)
        png_frames.each_with_index do |png_frame, i|
          duration = png_frame.delay_numerator.to_f / png_frame.delay_denominator.to_f
          @frames << create_frame_from_png("#{dir}/#{i}.png", id, duration)
        end
      end
    end

    def get_base64(path, id, width, height)
      bin = File.binread(path)
      base64 = [bin].pack('m')

      "<image id='image#{id}' width='#{width}' height='#{height}'
       xlink:href='data:image/png;base64,#{base64}'"
    end

    def save_rasterized(path)
      apngasm = APNGAsm.new

      Dir::mktmpdir(nil, File.dirname(__FILE__)) do |dir|
        @frames.each do |frame|
          # if File.extname(frame.path) == '.svg'
            convert_to_png(dir, frame)
            apngasm.add_frame_from_file("#{dir}/#{File.basename(frame.path, '.svg')}.png")
          # else
            # apngasm.add_frame_from_file(frame.path)
          # end
        end
      end

      apngasm.assemble(path)
      apngasm.reset
    end

    def convert_to_png(dir, frame)
      handle = RSVG::Handle.new_from_file(frame.path)
      surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, frame.width.to_i, frame.height.to_i)
      context = Cairo::Context.new(surface)
      context.render_rsvg_handle(handle)
      surface.write_to_png("#{dir}/#{File.basename(frame.path, '.svg')}.png")
    end
  end
end