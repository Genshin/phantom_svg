
require 'rexml/document'

require_relative '../frame.rb'
require_relative 'abstract_image_reader.rb'

module Phantom
  module SVG
    module Parser
      # SVG reader.
      class SVGReader < AbstractImageReader
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

        # Read no animation svg.
        def read_svg(options)
          read_images(@root, options)
        end

        # Read animation svg.
        def read_animation_svg(options)
          svg = @root.elements['svg']
          defs = svg.elements['defs']

          read_size(svg, self, options)
          read_images(defs, options)
          read_skip_first
          read_durations(options)
          read_loops
        end

        # Read size from node to dest.
        def read_size(node, dest, options = {})
          dest.viewbox.set_from_text(choice_value(node.attributes['viewBox'], options[:viewbox]).to_s) unless node.attributes['viewBox'].nil?

          if node.attributes['width'].nil? then
            dest.instance_variable_set(:@width, choice_value("#{dest.viewbox.width}px", options[:width]))
          else
            dest.instance_variable_set(:@width, choice_value(node.attributes['width'], options[:width]))
          end

          if node.attributes['height'].nil? then
            dest.instance_variable_set(:@height, choice_value("#{dest.viewbox.height}px", options[:height]))
          else
            dest.instance_variable_set(:@height, choice_value(node.attributes['height'], options[:height]))
          end
        end

        # Read images from svg.
        def read_images(parent_node, options)
          parent_node.elements.each('svg') do |svg|
            new_frame = Phantom::SVG::Frame.new

            # Read namespaces.
            new_frame.namespaces = svg.namespaces.clone
            new_frame.namespaces.merge!(options[:namespaces]) unless options[:namespaces].nil?

            # Read image size.
            read_size(svg, new_frame, options)

            # Read image surfaces.
            new_frame.surfaces = choice_value(svg.elements.to_a, options[:surfaces])

            # Read frame duration.
            new_frame.duration = choice_value(new_frame.duration, options[:duration])

            # Add frame to array.
            @frames << new_frame
          end
        end

        # Read skip_first.
        def read_skip_first
          @skip_first = @root.elements['svg/defs/symbol/use'].attributes['xlink:href'] != '#frame0'
        end

        # Read frame durations.
        def read_durations(options)
          i = @skip_first ? 1 : 0
          @root.elements['svg/defs/symbol'].elements.each('use') do |use|
            duration = use.elements['set'].attributes['dur'].to_f
            @frames[i].duration = choice_value(duration, options[:duration])
            i += 1
          end
        end

        # Read animation loop count.
        def read_loops
          @loops = @root.elements['svg/animate'].attributes['repeatCount'].to_i
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
