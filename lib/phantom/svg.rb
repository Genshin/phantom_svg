require 'cairo'
require 'nokogiri'

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
      create_frame(path) if File.extname(path) == '.svg'

      # TODO
      load_raster(path) if File.extname(path) == '.png'

      # TODO: もしフレームがあればframesに入れる
      # @frames << Phantom::SVG::Frame.new()
    end

    def create_frame(path)
      frame = Phantom::SVG::Frame.new

      data = Nokogiri::XML(File.read(path))
      data.css('svg').each do |svg|
        frame.width = svg.get_attribute('width')
        frame.height = svg.get_attribute('height')
      end
      data.css('g').each do |g|
        frame.surface = g
        break
      end

      @frames << frame
    end

    # Creates a blank frame when no arguments are passed
    # Takes another Phantom::SVG object or file path
    def add_frame(frame = nil)
      @frames << Phantom::SVG::Frame.new if frame.nil?

      # TODO もしPhantom::SVGなら情報をframeオブジェに入れてframesに追加
      if frame.instance_of?(Phantom::SVG)
        frame.frames.each do |f|
          @frames << f
        end
      end

      load_file(frame) if frame.instance_of?(String)
    end

    def save(path)
      # TODO
      # surface = Cairo::SVGSurface.new(path, @width, @height)
      surface = Cairo::SVGSurface.new(path, 100, 100)
      surface.finish

      data = write_data(path)

      File.write(path, data)
      clean(path)
    end

    def write_data(path)
      data = Nokogiri::XML(File.read(path))
      data.css('g').remove
      html = ""
      @frames.each_with_index do |frame, i|
        data.css('svg').each do |svg|
          g_tag = Nokogiri::XML::Node::new('g', data)
          g_tag.inner_html = "<set to='0' attributeName='opacity' />
                              <set to='1' from='0' begin='frame#{i}.begin'
                               end='frame#{i}.end' attributeName='opacity' />"
          g_tag.add_child(frame.surface)
          svg.add_child(g_tag)

          if i == 0
            # TODO dur
            html << "<animate id='frame#{i}'' begin='0s; frame#{@frames.size - 1}.end'' dur='1s' />"
          else
            html << "<animate id='frame#{i}' begin='frame#{i - 1}.end' dur='1s' />"
          end
        end
      end

      anim_tag = Nokogiri::XML::Node::new('g', data)
      anim_tag.set_attribute('id', 'frames')
      anim_tag.inner_html = html

      data.css('svg').each do |svg|
        svg.add_child(anim_tag)
      end

      data
    end

    def clean(path)
      data = File.open(path).read
      data.gsub!('<default:g>', '')
      data.gsub!('</default:g>', '')
      File.write(path, data)
    end
  end
end
