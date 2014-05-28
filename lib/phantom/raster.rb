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
      # frame.width = handle.dimentions.width
      # frame.height = handle.dimentions.height
      # frame.surface = get_base64(path, id)
      # frame.duration = duration unless duration.nil?

      pixbuf = Gdk::Pixbuf.new(path)

      frame = Phantom::SVG::Frame.new
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
      set_size

      apngasm = APNGAsm.new

      Dir::mktmpdir(nil, File.dirname(__FILE__)) do |dir|
        @frames.each_with_index do |frame, i|
          create_tmp_file("#{dir}/tmp#{i}", frame)
          apngasm.add_frame_file("#{dir}/tmp#{i}.png", frame.duration.to_f * 1000, 1000)
        end
      end

      apngasm.assemble(path)
      apngasm.reset
    end

    def create_tmp_file(path, frame)
      save_frame("#{path}.svg", frame, @width, @height)
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