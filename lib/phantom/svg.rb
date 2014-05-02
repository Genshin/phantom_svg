require 'cairo'

require_relative 'raster.rb'
require_relative 'svg/frame.rb'
require_relative 'svg/xml_parser.rb'

module Phantom
  module SVG
    class Base
      include Phantom::Raster
      include Phantom::XMLParser
      attr_accessor :frames

      def initialize(path = nil, options = {})
        @frames = []

        load_file(path, options) if path
      end

      def load_file(path, options = {})
        create_frame(path, options) if File.extname(path) == '.svg'

        load_raster(path, @frames.size) if File.extname(path) == '.png'
      end

      def create_frame(path, options = {})    
        if has_frame?(path)
          create_frame_from_xml(path)
        else
          @frames << Phantom::SVG::Frame.new(path, options)
        end
      end

      # Creates a blank frame when no arguments are passed
      # Takes another Phantom::SVG object or file path
      def add_frame(frame = nil, options = {})
        @frames << Phantom::SVG::Frame.new if frame.nil?

        if frame.instance_of?(Phantom::SVG::Base)
          frame.frames.each do |f|
            @frames << f
          end
        end

        @frames << frame if frame.instance_of?(Phantom::SVG::Frame)

        load_file(frame, options) if frame.instance_of?(String)
      end

      def set_size
        @width = 0
        @height = 0
        frames.each do |frame|
          @width = frame.width.to_f if frame.width.to_f > @width
          @height = frame.height.to_f if frame.height.to_f > @height
        end
      end

      def save(path)
        set_size
        surface = Cairo::SVGSurface.new(path, @width, @height)
        surface.finish

        data = write_all_data(path)

        File.write(path, data)
      end

      def save_frame(path, frame, width = frame.width.to_f, height = frame.height.to_f)
        surface = Cairo::SVGSurface.new(path, width, height)
        surface.finish

        data = write_frame_data(path, frame)

        File.write(path, data)
      end
    end
  end
end
