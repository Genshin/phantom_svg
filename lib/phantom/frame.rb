
module Phantom
  module SVG
    class Frame
      attr_accessor :duration, :surface, :width, :height, :viewbox, :namespaces

      def initialize(options = {})
        @duration = options[:duration].nil? ? 0.1 : options[:duration]
        @surface = options[:surface].nil? ? nil : options[:surface]
        @width = options[:width].nil? ? 64 : options[:width]
        @height = options[:height].nil? ? 64 : options[:height]
        @viewbox = 
          if options[:viewbox].nil?               then  ViewBox.new
          elsif options[:viewbox].is_a?(ViewBox)  then  options[:viewbox]
          elsif options[:viewbox].is_a?(String)   then  ViewBox.new.set_from_text(options[:viewbox])
          else                                          ViewBox.new
          end
        @namespaces = options[:namespaces].nil? ? {} : options[:namespaces]
      end

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
    end
  end
end
