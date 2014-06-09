
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
        i = 0
        @frames.each do |frame|
          create_file_list(frame[:name]).each do |file|
            if !File.exist?(file)
              if File.extname(file).empty?
                if File.exist?(file + '.svg')
                  file += '.svg'
                elsif File.exist?(file + '.png')
                  file += '.png'
                else
                end
              else
              end
            end

            options[:duration] = 
              if frame[:delay] != nil then  frame[:delay]
              elsif !@delays.empty?   then  @delays[i % @delays.length]
              else                          @default_delay
              end
            results << Phantom::SVG::Frame.new(file, options)
            i += 1
          end
        end

        Dir.chdir(old_dir)

        results
      end

      private
      def str2delay(str)
        tmp = str.to_s.split('/', 2)
        tmp[0].to_f / (tmp.length > 1 ? tmp[1].to_f : 1000.0)
      end

      def create_file_list(path)
        results = Dir.glob(path).sort_by { |k| k[/\d+/].to_i }
        if results.empty? then results << path end
        results
      end
    end # class JsonSpecReader
  end # module Spec
end # module Phantom
