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

      load_raster(path, @frames.size) if File.extname(path) == '.png'
    end

    def create_frame(path)
      xml = Nokogiri::XML(File.read(path))      
      if has_frame?(xml)
        create_frame_from_xml(path, xml)
      else
        @frames << Phantom::SVG::Frame.new(path)
      end
    end

    def create_frame_from_xml(path, xml)
      # TODO コード整理
      id = path.slice(0..path.length - 5)
      g_ids = []
      durs = []

      width = 0
      height = 0
      xml.css('svg').each do |svg|
        width = svg.get_attribute('width')
        height = svg.get_attribute('height')
      end

      xml.css('animate').each do |anim|
        g_ids << anim.values[0].slice(5..anim.values[0].length - 1)
        dur = anim.get_attribute('dur')
        durs << dur.delete('s')
      end

      xml.css('g').each do |g|
        unless g_ids.index(g.values[0]).nil?
          g.children.each do |child|
            if child.values[0] == 'contents'
              frame = Phantom::SVG::Frame.new
              frame.surface = child.child
              frame.width = width
              frame.height = height
              frame.duration = durs[g_ids.index(g.values[0])]
              frame.set_namespace(xml.namespaces)
              @frames << frame
            end
          end
        end
      end
    end

    def has_frame?(xml)
      result = false
      xml.css('g').each do |g|
        result = true if g.values[0] == 'frames'
      end
      result
    end

    # Creates a blank frame when no arguments are passed
    # Takes another Phantom::SVG object or file path
    def add_frame(frame = nil)
      @frames << Phantom::SVG::Frame.new if frame.nil?

      if frame.instance_of?(Phantom::SVG)
        frame.frames.each do |f|
          @frames << f
        end
      end

      @frames << frame if frame.instance_of?(Phantom::SVG::Frame)

      load_file(frame) if frame.instance_of?(String)
    end

    def set_size
      @width = 0
      @height = 0
      frames.each do |frame|
        @width = frame.width.to_f if frame.width.to_f > @width
        @height = frame.height.to_f if frame.height.to_f > @height
      end
    end

    def save(path)
      set_size
      surface = Cairo::SVGSurface.new(path, @width, @height)
      surface.finish

      data = write_data(path)

      File.write(path, data)
    end

    def write_data(path)
      data = Nokogiri::XML(File.read(path))

      # TODO コード整理
      id = path.slice(0..path.length - 5)

      data.css('g').remove
      html = ""
      @frames.each_with_index do |frame, i|
        data.css('svg').each do |svg|
          frame.namespaces.each do |key, value|
            svg.set_attribute(key, value)
          end

          g_tag = Nokogiri::XML::Node::new('g', data)
          g_tag.set_attribute('id', "#{id}_frame#{i}")
          g_tag.inner_html = "<set to='0' attributeName='opacity' /> <set to='1' from='0' begin='anim_#{id}_frame#{i}.begin'
                                    end='anim_#{id}_frame#{i}.end' attributeName='opacity' />"
          
          g_tag_child = Nokogiri::XML::Node::new('g', data)
          g_tag_child.set_attribute('id', 'contents')
          g_tag_child.add_child(frame.surface.to_s)
          g_tag.add_child(g_tag_child)
          svg.add_child(g_tag)

          if @frames.size == 1
            html << "<animate id='anim_#{id}_frame#{i}' begin='0s' dur='#{frame.duration}s' repeatCount='indefinite' />"
          elsif i == 0
            html << "<animate id='anim_#{id}_frame#{i}' begin='0s; anim_#{id}_frame#{@frames.size - 1}.end' dur='#{frame.duration}s' />"
          else
            html << "<animate id='anim_#{id}_frame#{i}' begin='anim_#{id}_frame#{i - 1}.end' dur='#{frame.duration}s' />"
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
  end
end
