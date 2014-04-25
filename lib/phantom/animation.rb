require_relative 'svg.rb'

module Phantom
  class Animation
    include Phantom::SVG

    # svg -> add_frame -> svg animation
    # apng -> add_frame -> svg animation
    # svg -> add_frame -> apng animation

  end
end