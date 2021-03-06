require_relative 'frame'
require_relative 'parser/png_reader'
require_relative 'parser/png_writer'
require_relative 'parser/svg_reader'
require_relative 'parser/svg_writer'
require_relative 'parser/jpeg_reader'
require_relative 'parser/gif_reader'
require_relative 'parser/json_animation_reader'
require_relative 'parser/xml_animation_reader'

module Phantom
  module SVG
    class Base
      attr_accessor :frames, :width, :height, :loops, :skip_first

      def initialize(path = nil, options = {})
        reset

        add_frame_from_file(path, options) if path
      end

      def reset
        @frames = []
        @width = 0
        @height = 0
        @loops = 0
        @skip_first = false
      end

      def add_frame_from_file(path, options = {})
        create_file_list(path).each do |file|
          load_file(file, options)
        end
      end

      def load_file(file, options)
        case File.extname(file).downcase
        when '.svg'   then  load_from_svg(file, options)
        when '.png'   then  load_from_png(file, options)
        when '.jpg'   then  load_from_jpeg(file, options)
        when '.jpeg'  then  load_from_jpeg(file, options)
        when '.gif'   then  load_from_gif(file, options)
        when '.json'  then  load_from_json(file, options)
        when '.xml'   then  load_from_xml(file, options)
        end
      end

      # Creates a blank frame when no arguments are passed
      # Takes another Phantom::SVG object or file path
      def add_frame(frame = nil, options = {})
        if    frame.nil?                              then @frames << Phantom::SVG::Frame.new
        elsif frame.instance_of?(Phantom::SVG::Frame) then @frames << frame
        elsif frame.instance_of?(Phantom::SVG::Base)  then @frames += frame.frames
        elsif frame.instance_of?(String)              then add_frame_from_file(frame, options)
        end
      end

      def set_size(width = nil, height = nil)
        set_width(width)
        set_height(height)
      end

      def set_width(width)
        if width.nil?
          if @width.nil? || @width == 0
            frames.each do |frame|
              @width = frame.width.to_i if frame.width.to_i > @width
            end
          end
        else
          @width = width
        end
      end

      def set_height(height)
        if height.nil?
          if @height.nil? || @height == 0
            frames.each do |frame|
              @height = frame.height.to_i if frame.height.to_i > @height
            end
          end
        else
          @height = height
        end
      end

      def scale_w(width)
        @height = (@height.to_i * width.to_i / @width.to_i).to_i
        @width = width.to_i
      end

      def scale_h(height)
        @width = (@width.to_i * height.to_i / @height.to_i).to_i
        @height = height.to_i
      end

      def save_svg(path)
        set_size

        Parser::SVGWriter.new.write(path, self)
      end

      def save_svg_frame(path, frame, width = nil, height = nil)
        old_width = frame.width
        old_height = frame.height
        frame.width = width unless width.nil?
        frame.height = height unless height.nil?

        write_size = Parser::SVGWriter.new.write(path, frame)

        frame.width = old_width
        frame.height = old_height

        write_size
      end

      def save_apng(path)
        Parser::PNGWriter.new.write(path, self)
      end

      # Calculate and return total duration.
      def total_duration
        result = 0.0
        @frames.each_with_index do |frame, i|
          next if i == 0 && @skip_first
          result += frame.duration
        end
        result
      end

      # Combine image.
      def combine(path)
        src = Base.new(path, {unique_ids: true})

        if @width != src.width || @height != src.height
          fail "Can't combine source images of different sizes."
          return
        end

        if @frames.length == 1
          rest_duration = (src.total_duration * 1000).to_i
          @frames[0].duration = rest_duration * 0.001
        elsif src.frames.length == 1
          rest_duration = (total_duration * 1000).to_i
          src.frames[0].duration = rest_duration * 0.001
        else
          rest_duration = (total_duration * 1000).to_i.lcm((src.total_duration * 1000).to_i)
        end

        base_i = src_i = -1
        base_duration = src_duration = 0;
        base_frame = src_frame = nil
        new_frames = []

        begin
          if base_duration == 0
            base_i = (base_i + 1) % @frames.length
            base_frame = @frames[base_i]
            base_duration = (base_frame.duration * 1000).to_i
          end

          if src_duration == 0
            src_i = (src_i + 1) % src.frames.length
            src_frame = src.frames[src_i]
            src_duration = (src_frame.duration * 1000).to_i
          end

          elapsed = [base_duration, src_duration].min

          new_frame = base_frame.clone
          new_frame.duration = elapsed * 0.001
          new_frame.surfaces += src_frame.surfaces
          new_frame.namespaces = src_frame.namespaces.merge(new_frame.namespaces)
          new_frames << new_frame

          base_duration -= elapsed
          src_duration -= elapsed
          rest_duration -= elapsed
        end while rest_duration > 0

        @frames = new_frames
      end

      private

      def load_from_svg(path, options)
        reader = Parser::SVGReader.new(path, options)
        
        if reader.has_animation?
          @loops = reader.loops
          @skip_first = reader.skip_first
        else
          @loops = 0
          @skip_first = false
        end

        @frames += reader.frames
        @width = reader.width
        @height = reader.height
      end

      def load_from_png(path, options)
        reader = Parser::PNGReader.new(path, options)
        
        if reader.has_animation?
          @loops = reader.loops
          @skip_first = reader.skip_first
        else
          @loops = 0
          @skip_first = false
        end

        @frames += reader.frames
        @width = reader.width
        @height = reader.height
      end

      def load_from_jpeg(path, options)
        reader = Parser::JPEGReader.new(path, options)
        
        if reader.has_animation?
          @loops = reader.loops
          @skip_first = reader.skip_first
        else
          @loops = 0
          @skip_first = false
        end

        @frames += reader.frames
        @width = reader.width
        @height = reader.height
      end

      def load_from_gif(path, option)
        reader = Parser::GIFReader.new(path, option)
        
        if reader.has_animation?
          @loops = reader.loops
          @skip_first = reader.skip_first
        else
          @loops = 0
          @skip_first = false
        end

        @frames += reader.frames
        @width = reader.width
        @height = reader.height
      end

      def load_from_json(path, options)
        load_from_reader(Parser::JSONAnimationReader.new(path), options)
      end

      def load_from_xml(path, options)
        load_from_reader(Parser::XMLAnimationReader.new(path), options)
      end

      def load_from_reader(reader, _options)
        if @frames.empty?
          @loops = reader.loops
          @skip_first = reader.skip_first
          @frames += reader.frames
          set_size
        elsif reader.skip_first
          @frames += reader.frames.slice(1, reader.frames.length - 1)
        else
          @frames += reader.frames
        end
      end

      def create_file_list(path)
        result = Dir.glob(path).sort_by { |k| k[/\d+/].to_i }
        result << path if result.empty?
        result
      end
    end
  end
end
