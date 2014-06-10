
require 'json'

require_relative '../svg/frame.rb'

module Phantom
  module Spec
    class JSONSpecReader
      # Construct JSONSpecReader object.
      def initialize
        @name = ''
        @loops = 0
        @skip_first = false
        @default_delay = 100.0 / 1000.0
        @frame_infos = []
        @delays = []
      end

      # Read and create frames from spec file.
      # Return array of Phantom::SVG::Frame.
      def read(path)
        # Read parameter from spec file.
        read_parameter(path)

        # Change current directory to spec file's directory.
        old_dir = Dir.pwd
        Dir.chdir(File.dirname(path))

        # Create frames from spec file parameter.
        result = create_frames

        # Change current directory to default.
        Dir.chdir(old_dir)

        # Return frames.
        result
      end

      private

      # Read parameter from spec file.
      def read_parameter(path)
        open(path) do |file|
          JSON.load(file).each do |key, val|
            case key
            when 'name'           then  @name = val.to_s
            when 'loops'          then  @loops = val.to_i
            when 'skip_first'     then  @skip_first = val.to_s == 'true' ? true : false
            when 'default_delay'  then  @default_delay = str2delay(val)
            when 'frames'         then  read_frame_infos(val)
            when 'delays'         then  val.each { |delay| @delays << str2delay(delay) }
            else                        # nop
            end
          end
        end
      end

      # Read frame informations
      def read_frame_infos(value)
        value.each do |frame_info|
          if frame_info.instance_of?(Hash)
            frame_info.each do |name, delay|
              @frame_infos << { name: name, delay: str2delay(delay) }
            end
          else
            @frame_infos << { name: frame_info }
          end
        end
      end

      # Create frames from parameter.
      # Return array of Phantom::SVG::Frame.
      def create_frames
        result = []
        i = 0
        @frame_infos.each do |frame_info|
          create_file_list(frame_info[:name]).each do |file|
            result << Phantom::SVG::Frame.new(file, create_options(i, frame_info[:delay]))
            i += 1
          end
        end

        result
      end

      # Create frame options.
      def create_options(index, delay_override)
        result = {}
        result[:duration] =
          if delay_override.nil?
            if @delays.empty? then  @default_delay
            else                    @delays[index % @delays.length]
            end
          else
            delay_override
          end
        result
      end

      # Create file list.
      def create_file_list(path)
        result = Dir.glob(path).sort_by { |k| k[/\d+/].to_i }
        if result.empty?
          result <<
            if    File.exist?(path)           then  path
            elsif File.exist?(path + '.svg')  then  path + '.svg'
            elsif File.exist?(path + '.png')  then  path + '.png'
            else                                    path # Illegal path.
            end
        end
        result
      end

      # Convert string to delay.
      def str2delay(str)
        tmp = str.to_s.split('/', 2)
        tmp[0].to_f / (tmp.length > 1 ? tmp[1].to_f : 1000.0)
      end
    end # class JsonSpecReader
  end # module Spec
end # module Phantom
