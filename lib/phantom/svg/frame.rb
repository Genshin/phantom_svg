require 'nokogiri'

module Phantom
  module SVG
    class Frame
      attr_accessor :duration, :surface, :width, :height, :path, :namespaces

      def initialize(path = nil)
        @path = path
        @duration = 1
        @namespaces = {}

        set_data_from_file(path) if path
      end

      def set_data_from_file(path)
        data = Nokogiri::XML(File.read(path))

        set_namespace(data.namespaces)

        data.css('svg').each do |svg|
          @width = svg.get_attribute('width')
          @height = svg.get_attribute('height')
        end

        data.css('g').each do |g|
          @surface = g
          break
        end
      end

      def set_namespace(data)
        data.each do |key, value|
          @namespaces[key] = value
        end
      end
    end
  end
end
