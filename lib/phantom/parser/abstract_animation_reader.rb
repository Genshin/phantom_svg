
require_relative 'svg_reader.rb'

module Phantom
  module SVG
    module Parser
      # AnimationReader base.
      class AbstractAnimationReader
        attr_accessor :frames, :loops, :skip_first

        # Construct AbstractAnimationReader object.
        def initialize(path = nil)
          reset
          read(path) unless path.nil?
        end

        # Read and create frames from animation information file.
        # Return array of Phantom::SVG::Frame.
        def read(path, do_reset = true)
          reset if do_reset

          # Read parameter from spec file.
          read_parameter(path)

          # Change current directory to animation information file's directory.
          old_dir = Dir.pwd
          Dir.chdir(File.dirname(path))

          # Create frames from animation information file parameter.
          create_frames

          # Change current directory to default.
          Dir.chdir(old_dir)

          # Return frames.
          @frames
        end

        private

        # Reset fields.
        def reset
          @name = ''
          @loops = 0
          @skip_first = false
          @default_delay = 100.0 / 1000.0
          @frame_infos = []
          @delays = []
          @frames = []
        end

        # Create frames from parameter.
        def create_frames
          i = 0
          @frame_infos.each do |frame_info|
            create_file_list(frame_info[:name]).each do |file|
              reader = Parser::SVGReader.new(file, create_options(i, frame_info[:delay]))
              @frames += reader.frames
              i += 1
            end
          end
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
              elsif File.exist?("#{path}.svg")  then  "#{path}.svg"
              elsif File.exist?("#{path}.png")  then  "#{path}.png"
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

        def set_parameter(key, val)
          case key
          when 'name'           then  @name = val.to_s
          when 'loops'          then  @loops = val.to_i
          when 'skip_first'     then  @skip_first = (val.to_s == 'true' ? true : false)
          when 'default_delay'  then  @default_delay = str2delay(val)
          else                        # nop
          end
        end

        def add_frame_info(name, delay = nil)
          @frame_infos << { name: name.to_s, delay: (delay.nil? ? delay : str2delay(delay)) }
        end

        def add_delay(delay)
          @delays << str2delay(delay)
        end
      end # class AbstractAnimationReader
    end # module Parser
  end # module SVG
end # module Phantom
