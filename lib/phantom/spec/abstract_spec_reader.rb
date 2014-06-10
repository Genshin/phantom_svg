
module Phantom
  module Spec
    class AbstractSpecReader
      # Construct AbstractSpecReader object.
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

      def set_name(name)
        @name = name.to_s
      end

      def set_loops(loops)
        @loops = loops.to_i
      end

      def set_skip_first(skip_first)
        @skip_first = (skip_first.to_s == 'true' ? true : false)
      end

      def set_default_delay(default_delay)
        @default_delay = str2delay(default_delay)
      end

      def add_frame_info(name, delay = nil)
        @frame_infos << { name: name.to_s, delay: str2delay(delay) }
      end

      def add_delay(delay)
        @delays << str2delay(delay)
      end
    end # class AbstractSpecReader
  end # module Spec
end # module Phantom
