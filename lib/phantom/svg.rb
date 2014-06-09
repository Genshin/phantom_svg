require 'cairo'

require_relative 'raster.rb'
require_relative 'svg/frame.rb'
require_relative 'svg/xml_parser.rb'
require_relative 'spec/json_spec_reader.rb'

module Phantom
  module SVG
    class Base
      include Phantom::Raster
      include Phantom::XMLParser
      attr_accessor :frames

      def initialize(path = nil, options = {})
        @frames = []

        add_frame_from_file(path, options) if path
      end

      def add_frame_from_file(path, options = {})
        case File.extname(path)
        when '.svg'   then load_from_svg(path, options)
        when '.png'   then load_from_png(path, options)
        when '.json'  then load_from_json(path, options)
        else
          # nop
        end
      end

      # Creates a blank frame when no arguments are passed
      # Takes another Phantom::SVG object or file path
      def add_frame(frame = nil, options = {})
        if    frame.nil?                              then @frames << Phantom::SVG::Frame.new
        elsif frame.instance_of?(Phantom::SVG::Frame) then @frames << frame
        elsif frame.instance_of?(Phantom::SVG::Base)  then frame.frames.each { |f| @frames << f }
        elsif frame.instance_of?(String)              then add_frame_from_file(frame, options)
        else  # nop
        end
      end

      def set_size
        @width = 0
        @height = 0
        frames.each do |frame|
          @width = frame.width.to_f if frame.width.to_f > @width
          @height = frame.height.to_f if frame.height.to_f > @height
        end
      end

      def save_svg(path)
        set_size
        surface = Cairo::SVGSurface.new(path, @width, @height)
        surface.finish

        data = write_all_data(path)

        File.write(path, data)
      end

      def save_png_frame(path, frame, width = frame.width.to_f, height = frame.height.to_f)
        surface = Cairo::SVGSurface.new(path, width, height)
        surface.finish

        data = write_frame_data(path, frame)

        File.write(path, data)
      end

      private
      def load_from_svg(path, options)
        if has_frame?(path)
          create_frame_from_xml(path)
        else
          @frames << Phantom::SVG::Frame.new(path, options)
        end
      end

      def load_from_png(path, options)
        load_raster(path, @frames.size)
      end

      def load_from_json(path, options)
        Phantom::Spec::JsonSpecReader.new.read(path)
      end
    end
  end
end
