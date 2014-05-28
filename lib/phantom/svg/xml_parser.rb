require 'nokogiri'

module Phantom
  module XMLParser
    def has_frame?(path)
      result = false

      xml = Nokogiri::XML(File.read(path)) 
      xml.css('g').each do |g|
        result = true if g.values[0] == 'frames'
      end

      result
    end

    def create_frame_from_xml(path)
      xml = Nokogiri::XML(File.read(path))

      id = path.slice(0..path.length - 5)

      width = 0
      height = 0
      xml.css('svg').each do |svg|
        width = svg.get_attribute('width').delete('pt')
        height = svg.get_attribute('height').delete('pt')
      end

      g_ids = []
      durs = []
      xml.css('animate').each do |anim|
        g_ids << anim.values[0].slice(5..anim.values[0].length - 1)
        durs << anim.get_attribute('dur').delete('s')
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
              frame.set_namespaces(xml.namespaces)
              @frames << frame
            end
          end
        end
      end
    end

    def set_namespaces(xml, frame)
      xml.css('svg').each do |svg|
        frame.namespaces.each do |key, value|
          svg.set_attribute(key, value) unless svg.namespaces.has_key?(key)
        end
      end
    end

    def write_all_data(path)
      xml = Nokogiri::XML(File.read(path))

      id = File.basename(path, '.svg')

      html = ""
      @ids = []
      @frames.each_with_index do |frame, i|
        set_namespaces(xml, frame)

        xml.css('svg').each do |svg|
          g_tag = Nokogiri::XML::Node::new('g', xml)
          g_tag.set_attribute('id', "#{id}_frame#{i}")
          g_tag.inner_html = "<set to='0' attributeName='opacity' /> <set to='1' from='0' begin='anim_#{id}_frame#{i}.begin'
                                    end='anim_#{id}_frame#{i}.end' attributeName='opacity' />"
          
          g_tag_child = Nokogiri::XML::Node::new('g', xml)
          g_tag_child.set_attribute('id', 'contents')

          if frame.surface.class != String
            frame.surface.children.each do |child|
              add_suffix(child, "#{id}_frame#{i}")
            end
            new_surface = rewrite_id(frame.surface.to_s, "#{id}_frame#{i}")
            g_tag_child.add_child(new_surface)
          else
            g_tag_child.add_child(frame.surface.to_s)
          end

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

      anim_tag = Nokogiri::XML::Node::new('g', xml)
      anim_tag.set_attribute('id', 'frames')
      anim_tag.inner_html = html

      xml.css('svg').each do |svg|
        svg.add_child(anim_tag)
      end

      xml
    end

    def add_suffix(contents, suffix)
      if contents.children.length != 0
        for i in 0..contents.children.length - 1
          add_suffix(contents.children[i], suffix)
        end
      end

      if contents.has_attribute?('id')
        name = contents.get_attribute('id')
        @ids << name
        contents.set_attribute('id', "#{name}_#{suffix}");
      end
    end

    def rewrite_id(surface, suffix)
      @ids.each do |id|
        surface.gsub!("url(##{id})", "url(##{id}_#{suffix})")
      end
      surface
    end

    def write_frame_data(path, frame)
      xml = Nokogiri::XML(File.read(path))
      set_namespaces(xml, frame)

      xml.css('g').each do |g|
        g.add_child(frame.surface.to_s)
      end

      xml
    end
  end
end