require 'rsvg2'
require 'cairo'
# require 'nokogiri'

require_relative 'raster.rb'
require_relative 'svg/frame.rb'

module Phantom
  module SVG
    include Phantom::Raster
    attr_accessor :frames

    def initialize(path = nil)
      @frames = []
      load_file(path) if path
    end

    def load_file(path)
      # TODO: もしSVGならそのまま開く
      if File.extname(path) == '.svg'
        handle = RSVG::Handle.new_from_file(path)
        # @svg = Nokogiri::XML(File.read(path))
      end

      load_raster(path) if File.extname(path) == '.png'

      # TODO: もしフレームがあればframesに入れる
      # @frames << Phantom::SVG::Frame.new()
    end

    # Creates a blank frame when no arguments are passed
    # Takes another Phantom::SVG object or file path
    def add_frame(frame = nil)
      @frames << Phantom::SVG::Frame.new if frame.nil?

      # TODO もしPhantom::SVGなら情報をframeオブジェに入れてframesに追加
      if frame.instance_of(Phantom::SVG)
      end

      # TODO もしファイルパスなら読み込む
      if frame.instance_of(String)
        load_file(frame)
      end
    end

    def save(path)
      # TODO
      # File.write(path, @svg)
    end
  end
end
