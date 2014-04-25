module Phantom
  module SVG
    class Frame
      attr_accessor :start_time, :duration, :surface

      def initialize(start_time = nil, duration = nil, surface = nil)
        @start_time = start_time
        @duration = duration
        @surface = surface
      end
    end
  end
end
