
require 'rexml/document'
require 'digest/md5'

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

          @path = path
          @marker = Digest::MD5.hexdigest(open(@path).read)

          @root = REXML::Document.new(open(path))
          make_ids_unique() if options[:unique_ids] == true

          if @root.elements['svg'].attributes['id'] == 'phantom_svg'
            read_animation_svg(options)
            @has_animation = true
          else
            read_svg(options)
            @has_animation = false
          end
        end

        private

        # Make ID's and their references unique so they don't collide with other layers/frames.
        def make_ids_unique(element_types = ['linearGradient', 'radialGradient'])
          element_types.each { |element_type| make_id_unique(element_type) }
        end

        def make_id_unique(element_type)
          @root.elements.each("//#{element_type}") do |element|
            id = element.attributes['id']
            new_id = id + @marker
            element.attributes['id'] = new_id
            _replace_id_refs(id, new_id)
          end
        end

        def _replace_id_refs(id, new_id)
          @root.elements.each("//*") do |element|
            element.attributes['style'].gsub!(/url\(\##{id}\)/, "url(\##{new_id})") if element.attributes['style'] != nil
            element.attributes['fill'].gsub!(/\##{id}$/, "\##{new_id}") if element.attributes['fill'] != nil
            element.attributes['xlink:href'].gsub!(/\##{id}$/, "\##{new_id}") if element.attributes['xlink:href'] != nil
          end
        end

        # Read no animation svg.
        def read_svg(options)
          read_images(@root, options)
          @width = @frames.first.width
          @height = @frames.first.height
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
          set_view_box(node, dest, options)
          set_width(node, dest, options)
          set_height(node, dest, options)
        end

        def set_view_box(node, dest, options = {})
          return if node.attributes['viewBox'].nil?
          dest.viewbox.set_from_text(choice_value(node.attributes['viewBox'],
                                                  options[:viewbox]).to_s)
        end

        def set_width(node, dest, options = {})
          if node.attributes['width'].nil?
            dest.instance_variable_set(:@width,
                                       choice_value("#{dest.viewbox.width}px", options[:width]))
          else
            dest.instance_variable_set(:@width,
                                       choice_value(node.attributes['width'], options[:width]))
          end
        end

        def set_height(node, dest, options = {})
          if node.attributes['height'].nil?
            dest.instance_variable_set(:@height,
                                       choice_value("#{dest.viewbox.height}px", options[:height]))
          else
            dest.instance_variable_set(:@height,
                                       choice_value(node.attributes['height'], options[:height]))
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
          use = @root.elements['svg/defs/symbol/use']
          @skip_first = use.nil? ? @frames.size > 1 : use.attributes['xlink:href'] != '#frame0'
        end

        # Read frame durations.
        def read_durations(options)
          symbol = @root.elements['svg/defs/symbol']
          return if symbol.nil?

          i = @skip_first ? 1 : 0
          symbol.elements.each('use') do |use|
            duration = use.elements['set'].attributes['dur'].to_f
            @frames[i].duration = choice_value(duration, options[:duration])
            i += 1
          end
        end

        # Read animation loop count.
        def read_loops
          animate = @root.elements['svg/animate']
          @loops = animate.nil? ? 0 : animate.attributes['repeatCount'].to_i
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
