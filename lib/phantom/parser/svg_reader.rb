
require 'rexml/document'

require_relative '../frame.rb'

module Phantom
  module SVG
    module Parser
      # SVG reader.
      class SVGReader
        attr_reader :frames, :width, :height, :loops, :skip_first, :has_animation
        alias_method :has_animation?, :has_animation

        # Construct SVGReader object.
        def initialize(path = nil, options = {})
          read(path, options)
        end

        # Read svg file from path.
        def read(path, options = {})
          reset

          return if path.nil? || path.empty?

          @root = REXML::Document.new(open(path))

          if @root.elements['svg'].attributes['id'] == 'phantom_svg'
            read_animation_svg(options)
            @has_animation = true
          else
            read_svg(options)
            @has_animation = false
          end
        end

        private

        # Reset SVGReader object.
        def reset
          @frames = []
          @width = nil
          @height = nil
          @loops = nil
          @skip_first = nil
          @has_animation = false
        end

        # Read no animation svg.
        def read_svg(options)
          new_frame = Frame.new
          svg = @root.elements['svg']

          new_frame.namespaces = svg.namespaces
          new_frame.namespaces.merge!(options[:namespaces]) unless options[:namespaces].nil?

          svg.attributes.each do |key, val|
            case key
            when 'width'    then  new_frame.width = choice_value(val, options[:width])
            when 'height'   then  new_frame.height = choice_value(val, options[:height])
            when 'viewBox'  then  new_frame.viewbox.set_from_text(choice_value(val, options[:viewbox]).to_s)
            else                    # nop
            end
          end

          new_frame.surface = choice_value(svg.elements, options[:surface])
          new_frame.duration = options[:duration] unless options[:duration].nil?

          # Add frame to array.
          @frames << new_frame
        end

        # Read animation svg.
        def read_animation_svg(options)
          svg = @root.elements['svg']
          defs = svg.elements['defs']

          svg.attributes.each do |key, val|
            case key
            when 'width'    then  @width = choice_value(val, options[:width])
            when 'height'   then  @height = choice_value(val, options[:height])
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

          if defs_symbol.elements['use'].attributes['xlink:href'] == '#frame0'
            @skip_first = false
          else
            @skip_first = true
            i = 1
          end

          defs_symbol.elements.each('use') do |use|
            current_frame = @frames[i]
            current_frame.duration = use.elements['set'].attributes['dur'].to_f if options[:duration].nil?
            i += 1
          end

          # Read loop count.
          @loops = svg.elements['animate'].attributes['repeatCount'].to_i
        end

        # Helper method.
        # Return val if override is nil.
        # Return override if override is not nil.
        def choice_value(val, override)
          override.nil? ? val : override
        end
      end # class SVGReader
    end # module Parser
  end # module SVG
end # module Phantom
