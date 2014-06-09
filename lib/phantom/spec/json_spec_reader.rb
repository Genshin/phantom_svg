
require 'json'

require_relative '../svg/frame.rb'

module Phantom
  module Spec
    class JsonSpecReader
      def initialize()
        @name = ""
        @loops = 0
        @skip_first = false
        @default_delay = 100.0 / 1000.0
        @frames = []
        @delays = []
      end

      def read(path)
        open(path) do |file|
          JSON.load(file).each do |key, val|
            case key
            when 'name'
              @name = val.to_s
            when 'loops'
              @loops = val.to_i
            when 'skip_first'
              @skip_first = val.to_s == 'true' ? true : false
            when 'default_delay'
              @default_delay = str2delay(val)
            when 'frames'
              val.each do |frame|
                if frame.instance_of?(Hash)
                  frame.each do |name, delay|
                    @frames << { :name=>name, :delay=>str2delay(delay) }
                  end
                else
                  @frames << { :name=>frame }
                end
              end
            when 'delays'
              val.each do |delay|
                @delays << str2delay(delay)
              end
            else
              # nop
            end
          end
        end

        old_dir = Dir.pwd()
        Dir.chdir(File.dirname(path))

        results = []
        options = {}
        range = 0..(@frames.length - 1)
        range.each do |i|
          frame = @frames[i]
          if !File.exist?(frame[:name])
            if File.extname(frame[:name]).empty?
              if File.exist?(frame[:name] + '.svg')
                frame[:name] += '.svg'
              elsif File.exist?(frame[:name] + '.png')
                frame[:name] += '.png'
              else
                next
              end
            else
              next
            end
          end

          options[:duration] = 
            if frame[:delay] != nil then  frame[:delay]
            elsif !@delays.empty?   then  @delays[i % @delays.length]
            else                          @default_delay
            end
          results << Phantom::SVG::Frame.new(frame[:name], options)
        end

        Dir.chdir(old_dir)

        results
      end

      private
      def str2delay(str)
        tmp = str.to_s.split('/', 2)
        tmp[0].to_f / (tmp.length > 1 ? tmp[1].to_f : 1000.0)
      end
    end # class JsonSpecReader
  end # module Spec
end # module Phantom
