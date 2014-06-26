
require 'rexml/document'

require_relative '../frame.rb'

module Phantom
  module SVG
    module Parser
      class SVGReader
        attr_reader :frames, :width, :height, :loops, :skip_first

        def initialize(path = nil, options = {})
          read(path)
        end

        def read(path, options = {})
          reset

          @root = REXML::Document.new(open(path))

          if @root.elements['svg'].attributes['id'] == 'phantom_svg'
            read_animation_svg(options)
            @has_animation = true
          else
            read_svg(options)
            @has_animation = false
          end
        end

        def has_animation?
          return @has_animation
        end

        private

        def reset
          @frames = []
          @width = nil
          @height = nil
          @loops = nil
          @skip_first = nil
          @has_animation = false
        end

        def read_svg(options)
          new_frame = Frame.new(options)
          svg = @root.elements['svg']

          new_frame.namespaces = svg.namespaces

          svg.attributes.each do |key, val|
            case key
            when 'width'    then  new_frame.width = val if options[:width].nil?
            when 'height'   then  new_frame.height = val if options[:height].nil?
            when 'viewBox'  then  new_frame.viewbox.set_from_text(val) if options[:viewbox].nil?
            else                  # nop
            end
          end

          new_frame.surface = svg.elements

          # Add frame to array.
          @frames << new_frame
        end

        def read_animation_svg(options)
          svg = @root.elements['svg']
          defs = svg.elements['defs']

          svg.attributes.each do |key, val|
            case key
            when 'width'    then  @width = options[:width].nil? ? val : options[:width]
            when 'height'   then  @height = options[:height].nil? ? val : options[:height]
            else                  # nop
            end
          end

          # Read images.
          defs.elements.each('svg') do |defs_svg|
            new_frame = Frame.new(options)
            defs_svg.attributes.each do |key, val|
              case key
              when 'width'    then  new_frame.width = val
              when 'height'   then  new_frame.height = val
              when 'viewBox'  then  new_frame.viewbox.set_from_text(val)
              else                  # nop
              end
            end
            new_frame.namespaces = defs_svg.namespaces if options[:namespaces].nil?
            new_frame.surface = defs_svg.elements
            @frames << new_frame
          end

          # Read animation.
          defs_symbol = defs.elements['symbol']
          i = 0

          if defs_symbol.elements['use'].attributes['xlink:href'] != '#frame0'
            @skip_first = true
            i = 1
          end

          defs_symbol.elements.each('use') do |use|
            current_frame = @frames[i]
            current_frame.duration = use.elements['set'].attributes['dur'].to_f if options[:duration].nil?
            i = i + 1
          end

          # Read loop count.
          @loops = svg.elements['animate'].attributes['repeatCount'].to_i
        end
      end # class SVGReader
    end # module Parser
  end # module SVG
end # module Phantom
