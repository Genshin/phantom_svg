require 'nokogiri'

module Phantom
  module SVG
    class Frame
      attr_accessor :duration, :surface, :width, :height, :path

      def initialize(path = nil)
        set_data_from_file(path) if path
        @path = path
        @duration = 1
      end

      def set_data_from_file(path)
        data = Nokogiri::XML(File.read(path))

        data.css('svg').each do |svg|
          @width = svg.get_attribute('width')
          @height = svg.get_attribute('height')
        end

        data.css('g').each do |g|
          @surface = g
          break
        end
      end
    end
  end
end
