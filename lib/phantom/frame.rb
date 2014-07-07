
module Phantom
  module SVG
    # Frame class for "Key Frames" implementation in SVG
    class Frame
      attr_accessor :duration, :surfaces, :width, :height, :viewbox, :namespaces

      def initialize(options = {})
        set_duration(options[:duration])
        set_surfaces(options[:surfaces])
        set_width(options[:width])
        set_height(options[:height])
        set_viewbox(options[:viewbox])
        set_namespaces(options[:namespaces])
      end

      # ViewBox helper.
      class ViewBox
        attr_accessor :x, :y, :width, :height

        def initialize(x = 0, y = 0, width = 64, height = 64)
          @x = x
          @y = y
          @width = width
          @height = height
        end

        def set_from_text(text)
          values = text.split(' ', 4)
          initialize(values[0], values[1], values[2], values[3])
          self
        end

        def to_s
          "#{@x.to_i} #{@y.to_i} #{@width.to_i} #{@height.to_i}"
        end
      end

      private

      def set_duration(val)
        @duration = val.nil? ? 0.1 : val
      end

      def set_surfaces(val)
        @surfaces = val.nil? ? nil : val
      end

      def set_width(val)
        @width = val.nil? ? 64 : val
      end

      def set_height(val)
        @height = val.nil? ? 64 : val
      end

      def set_viewbox(val)
        @viewbox =
          if val.nil?               then  ViewBox.new
          elsif val.is_a?(ViewBox)  then  val
          elsif val.is_a?(String)   then  ViewBox.new.set_from_text(val)
          else                            ViewBox.new
          end
      end

      def set_namespaces(val)
        @namespaces = val.nil? ? {} : val
      end
    end
  end
end
