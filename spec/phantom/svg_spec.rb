require 'phantom/svg'

# Set Current directory.
Dir.chdir(SPEC_ROOT_DIR)

describe Phantom::SVG::Base do

  describe 'loading a non-animated svg' do
    before(:all) do
      @image_name = 'plain'
      @source = "#{SPEC_SOURCE_DIR}/#{@image_name}.svg"
    end

    before do
      @loader = Phantom::SVG::Base.new(@source)
    end

    it 'frames vector has a size of 1.' do
      expect(@loader.frames.size).to eq(1)
    end

    it 'frame duration equals 0.1.' do
      expect(@loader.frames[0].duration).to eq(0.1)
    end

    it 'frame surfaces is not nil.' do
      expect(@loader.frames[0].surfaces).not_to be_nil
    end

    it 'frame surfaces is not empty.' do
      expect(@loader.frames[0].surfaces).not_to be_empty
    end

    it 'frame width equal to 64.' do
      expect(@loader.frames[0].width).to eq('64')
    end

    it 'frame height equal to 64.' do
      expect(@loader.frames[0].height).to eq('64')
    end

    it 'frame namespaces is not empty.' do
      expect(@loader.frames[0].namespaces).not_to be_empty
    end

    after do
      # nop
    end
  end

  describe 'creating an animated SVG' do
    before(:all) do
      @image_name = 'test_frames'
      @source = "#{SPEC_SOURCE_DIR}/#{@image_name}/*.svg"
      @destination_dir = "#{SPEC_TEMP_DIR}/#{@image_name}"
      @destination = "#{@destination_dir}/#{@image_name}.svg"
      FileUtils.mkdir_p(@destination_dir)
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'saves a non-zero-byte file.' do
      @loader.add_frame_from_file(@source)
      write_size = @loader.save_svg(@destination)
      expect(write_size).not_to eq(0)
    end

    it 'is an animation with a frame vector size of 12.' do
      @loader.add_frame_from_file(@destination)
      expect(@loader.frames.size).to eq(12)
    end

    it ' has a frame surfaces length not equal to 1.' do
      @loader.add_frame_from_file(@destination)

      range = 0..(@loader.frames.length - 1)
      range.each do |i|
        frame = @loader.frames[i]
        expect(frame.surfaces.to_s.length).not_to eq(1)

        @loader.save_svg_frame("#{@destination_dir}/#{i}.svg", frame)
      end
    end

    after do
      # nop
    end
  end

  describe 'creating an animated SVG file from a JSON animation spec file' do
    before(:all) do
      @image_name = 'test_frames'
      @source_dir = "#{SPEC_SOURCE_DIR}/#{@image_name}"
      @destination_dir = SPEC_TEMP_DIR
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'loads frames from "test1.json".' do
      test_name = 'test1'
      @loader.add_frame_from_file("#{@source_dir}/#{test_name}.json")
      expect(@loader.frames.size).to eq(12)
      @loader.frames.each do |frame|
        expect(frame.duration.instance_of?(Float)).to eq(true)
        expect(frame.width).to eq('64px')
        expect(frame.height).to eq('64px')
        expect(frame.surfaces).not_to be_nil
        expect(frame.surfaces).not_to be_empty
        expect(frame.surfaces.to_s.length).not_to eq(1)
        expect(frame.namespaces).not_to be_empty
      end
      write_size = @loader.save_svg("#{@destination_dir}/json_#{test_name}.svg")
      expect(write_size).not_to eq(0)
    end

    it 'loads frames from "test2.json".' do
      test_name = 'test2'
      @loader.add_frame_from_file("#{@source_dir}/#{test_name}.json")
      expect(@loader.frames.size).to eq(12)
      @loader.frames.each do |frame|
        expect(frame.duration.instance_of?(Float)).to eq(true)
        expect(frame.width).to eq('64px')
        expect(frame.height).to eq('64px')
        expect(frame.surfaces).not_to be_nil
        expect(frame.surfaces).not_to be_empty
        expect(frame.surfaces.to_s.length).not_to eq(1)
        expect(frame.namespaces).not_to be_empty
      end
      write_size = @loader.save_svg("#{@destination_dir}/json_#{test_name}.svg")
      expect(write_size).not_to eq(0)
    end
  end

  describe 'creating an animated SVG from file from an XML animation spec' do
    before(:all) do
      @image_name = 'test_frames'
      @source_dir = "#{SPEC_SOURCE_DIR}/#{@image_name}"
      @destination_dir = SPEC_TEMP_DIR
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'loads frames from "test1.xml".' do
      test_name = 'test1'
      @loader.add_frame_from_file("#{@source_dir}/#{test_name}.xml")
      expect(@loader.frames.size).to eq(12)
      @loader.frames.each do |frame|
        expect(frame.duration.instance_of?(Float)).to eq(true)
        expect(frame.width).to eq('64px')
        expect(frame.height).to eq('64px')
        expect(frame.surfaces).not_to be_nil
        expect(frame.surfaces).not_to be_empty
        expect(frame.surfaces.to_s.length).not_to eq(1)
        expect(frame.namespaces).not_to be_empty
      end
      write_size = @loader.save_svg("#{@destination_dir}/xml_#{test_name}.svg")
      expect(write_size).not_to eq(0)
    end

    it 'load frames from "test2.xml".' do
      test_name = 'test2'
      @loader.add_frame_from_file("#{@source_dir}/#{test_name}.xml")
      expect(@loader.frames.size).to eq(12)
      @loader.frames.each do |frame|
        expect(frame.duration.instance_of?(Float)).to eq(true)
        expect(frame.width).to eq('64px')
        expect(frame.height).to eq('64px')
        expect(frame.surfaces).not_to be_nil
        expect(frame.surfaces).not_to be_empty
        expect(frame.surfaces.to_s.length).not_to eq(1)
        expect(frame.namespaces).not_to be_empty
      end
      write_size = @loader.save_svg("#{@destination_dir}/xml_#{test_name}.svg")
      expect(write_size).not_to eq(0)
    end
  end

  describe 'converting a keyframe animated SVG to APNG' do
    before(:all) do
      @image_name = 'test_frames'
      @source = "#{SPEC_SOURCE_DIR}/#{@image_name}/*.svg"
      @destination = "#{SPEC_TEMP_DIR}/svg2apng.png"
    end

    before do
      options = { duration: 0.5 }
      @loader = Phantom::SVG::Base.new(@source, options)
    end

    it 'successfully converts.' do
      expect(@loader.frames.size).to eq(12)
      expect(@loader.save_apng(@destination)).to eq(true)
    end

    it 'stretches horizontally' do
      expect(@loader.frames.size).to eq(12)
      @loader.width = 128
      expect(@loader.save_apng("#{SPEC_TEMP_DIR}/svg2apng_h.png")).to eq(true)
    end

    it 'stretches vertically' do
      expect(@loader.frames.size).to eq(12)
      @loader.height = 128
      expect(@loader.save_apng("#{SPEC_TEMP_DIR}/svg2apng_v.png")).to eq(true)
    end
  end

  describe 'converting an APNG to a keyframe animated SVG' do
    before(:all) do
      @apng_name = 'apngasm'
      @source = "#{SPEC_SOURCE_DIR}/#{@apng_name}.png"
      @destination_dir = "#{SPEC_TEMP_DIR}/#{@apng_name}"
      @destination = "#{@destination_dir}/#{@apng_name}.svg"
      FileUtils.mkdir_p(@destination_dir)
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'loads and saves PNG.' do
      @loader.add_frame_from_file("#{SPEC_SOURCE_DIR}/test_raster.png")
      expect(@loader.frames.size).to eq(1)
      expect(@loader.frames.first.width).to eq('256px')
      expect(@loader.frames.first.height).to eq('128px')
      expect(@loader.frames.first.viewbox.width).to eq(256)
      expect(@loader.frames.first.viewbox.height).to eq(128)

      write_size = @loader.save_svg("#{SPEC_TEMP_DIR}/static_same.svg")
      expect(write_size).not_to eq(0)
      @loader.width = 64
      @loader.height = 32
      write_size = @loader.save_svg("#{SPEC_TEMP_DIR}/static_scaled.svg")
      expect(write_size).not_to eq(0)
    end

    it 'loads and saves an irrigularly proportioned PNG' do
      @loader.add_frame_from_file("#{SPEC_SOURCE_DIR}/small_v_raster.png")
      expect(@loader.frames.size).to eq(1)
      expect(@loader.frames.first.width).to eq('33px')
      expect(@loader.frames.first.height).to eq('54px')
      expect(@loader.frames.first.viewbox.width).to eq(33)
      expect(@loader.frames.first.viewbox.height).to eq(54)

      write_size = @loader.save_svg("#{SPEC_TEMP_DIR}/small_v_same.svg")
      expect(write_size).not_to eq(0)

      @loader.width = 64
      @loader.height = 32
      write_size = @loader.save_svg("#{SPEC_TEMP_DIR}/small_v_scaled.svg")
      expect(write_size).not_to eq(0)
    end

    it 'loads an APNG and saves a smaller APNG.' do
      @loader.add_frame_from_file(@source)
      expect(@loader.frames.size).to eq(34)

      @loader.width = 12
      @loader.height = 12
      write_size = @loader.save_apng("#{SPEC_TEMP_DIR}/apng_scaled.png")
      expect(write_size).not_to eq(0)
    end

    it 'loads an APNG and saves a bigger APNG.' do
      @loader.add_frame_from_file(@source)
      expect(@loader.frames.size).to eq(34)

      @loader.width = 128
      @loader.height = 128
      write_size = @loader.save_apng("#{SPEC_TEMP_DIR}/apng_scaled_up.png")
      expect(write_size).not_to eq(0)
    end

    it 'loads an APNG and saves a horizontally stretched APNG.' do
      @loader.add_frame_from_file(@source)
      expect(@loader.frames.size).to eq(34)

      @loader.width = 80
      @loader.height = 20
      write_size = @loader.save_apng("#{SPEC_TEMP_DIR}/apng_h_stretched.png")
      expect(write_size).not_to eq(0)
    end

    it 'loads an APNG and saves a vertically stretched APNG.' do
      @loader.add_frame_from_file(@source)
      expect(@loader.frames.size).to eq(34)

      @loader.width = 20
      @loader.height = 80
      write_size = @loader.save_apng("#{SPEC_TEMP_DIR}/apng_v_stretched.png")
      expect(write_size).not_to eq(0)
    end

    it 'loads an APNG and saves a keyframe animated SVG.' do
      @loader.add_frame_from_file(@source)
      expect(@loader.frames.size).to eq(34)

      write_size = @loader.save_svg(@destination)
      expect(write_size).not_to eq(0)

      range = 0..(@loader.frames.length - 1)
      range.each do |i|
        frame = @loader.frames[i]
        write_size = @loader.save_svg_frame("#{@destination_dir}/#{i}.svg", frame)
        expect(write_size).not_to eq(0)
      end
    end

    it 'adds frames.' do
      @loader.add_frame_from_file(@destination)
      expect(@loader.frames.size).to eq(34)

      @loader.frames.each do |frame|
        expect(frame.duration).to eq(0.1)
        expect(frame.width).to eq('64px')
        expect(frame.height).to eq('64px')
        expect(frame.surfaces.to_s.length).not_to eq(0)
        expect(frame.namespaces.length).not_to eq(0)
      end
    end
  end

  describe 'using a finite loop count' do
    before(:all) do
      @image_name = 'test_frames'
      @source_dir = "#{SPEC_SOURCE_DIR}/#{@image_name}"
      @source = "#{@source_dir}/*.svg"
      @destination_dir = SPEC_TEMP_DIR
      @destination_svg = "#{@destination_dir}/loops_test.svg"
      @destination_png = "#{@destination_dir}/loops_test.png"
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'saves a keyframe animated SVG.' do
      @loader.add_frame_from_file(@source)
      @loader.loops = 2

      write_size = @loader.save_svg(@destination_svg)
      expect(write_size).not_to eq(0)
    end

    it 'correctly saved the keyframe animated SVG.' do
      @loader.add_frame_from_file(@destination_svg)

      expect(@loader.frames.size).to eq(12)
      expect(@loader.width).to eq('64px')
      expect(@loader.height).to eq('64px')
      expect(@loader.loops).to eq(2)
      expect(@loader.skip_first).to eq(false)
    end

    it 'exports/saves to APNG.' do
      @loader.add_frame_from_file(@source)
      @loader.loops = 2

      write_size = @loader.save_apng(@destination_png)
      expect(write_size).not_to eq(0)
    end

    it 'correctly saved the APNG.' do
      @loader.add_frame_from_file(@destination_png)

      expect(@loader.frames.size).to eq(12)
      expect(@loader.width).to eq('64px')
      expect(@loader.height).to eq('64px')
      expect(@loader.loops).to eq(2)
      expect(@loader.skip_first).to eq(false)
    end

    it 'loads an animation spec from a JSON file.' do
      test_name = 'loops_test'
      source = "#{@source_dir}/#{test_name}.json"
      destination = "#{@destination_dir}/#{test_name}_json.svg"

      @loader.add_frame_from_file(source)
      @loader.save_svg(destination)
      @loader.reset
      @loader.add_frame_from_file(destination)

      expect(@loader.frames.size).to eq(12)
      expect(@loader.width).to eq('64px')
      expect(@loader.height).to eq('64px')
      expect(@loader.loops).to eq(3)
      expect(@loader.skip_first).to eq(false)
      expect(@loader.frames[0].duration).to eq(0.05)
    end

    it 'loads an animation spec from an XML file.' do
      test_name = 'loops_test'
      source = "#{@source_dir}/#{test_name}.xml"
      destination = "#{@destination_dir}/#{test_name}_xml.svg"

      @loader.add_frame_from_file(source)
      @loader.save_svg(destination)
      @loader.reset
      @loader.add_frame_from_file(destination)

      expect(@loader.frames.size).to eq(12)
      expect(@loader.width).to eq('64px')
      expect(@loader.height).to eq('64px')
      expect(@loader.loops).to eq(3)
      expect(@loader.skip_first).to eq(false)
      expect(@loader.frames[0].duration).to eq(0.05)
    end
  end

  describe 'using the skip_first flag' do
    before(:all) do
      @image_name = 'test_frames'
      @source_dir = "#{SPEC_SOURCE_DIR}/#{@image_name}"
      @source = "#{@source_dir}/*.svg"
      @source_skip_frame = "#{SPEC_SOURCE_DIR}/compiled.svg"
      @destination_dir = SPEC_TEMP_DIR
      @destination_svg = "#{@destination_dir}/skip_first_test.svg"
      @destination_png = "#{@destination_dir}/skip_first_test.png"
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'can save a keyframe animated SVG' do
      @loader.add_frame_from_file(@source_skip_frame)
      @loader.add_frame_from_file(@source)
      @loader.skip_first = true

      write_size = @loader.save_svg(@destination_svg)
      expect(write_size).not_to eq(0)
    end

    it 'successfully saves a keyframe animated SVG.' do
      @loader.add_frame_from_file(@destination_svg)

      expect(@loader.frames.size).to eq(24)
      expect(@loader.width).to eq('64px')
      expect(@loader.height).to eq('64px')
      expect(@loader.loops).to eq(0)
      expect(@loader.skip_first).to eq(true)
    end

    it 'exports/saves to APNG' do
      @loader.add_frame_from_file(@source_skip_frame)
      @loader.add_frame_from_file(@source)
      @loader.skip_first = true

      write_size = @loader.save_apng(@destination_png)
      expect(write_size).not_to eq(0)
    end

    it 'correctly saved an APNG.' do
      @loader.add_frame_from_file(@destination_png)

      expect(@loader.frames.size).to eq(24)
      expect(@loader.width).to eq('64px')
      expect(@loader.height).to eq('64px')
      expect(@loader.loops).to eq(0)
      expect(@loader.skip_first).to eq(true)
    end

    it 'loads an animation spec from a JSON.' do
      test_name = 'skip_first_test'
      source = "#{@source_dir}/#{test_name}.json"
      destination = "#{@destination_dir}/#{test_name}_json.svg"

      @loader.add_frame_from_file(source)
      @loader.save_svg(destination)
      @loader.reset
      @loader.add_frame_from_file(destination)

      expect(@loader.frames.size).to eq(24)
      expect(@loader.width).to eq('64px')
      expect(@loader.height).to eq('64px')
      expect(@loader.loops).to eq(0)
      expect(@loader.skip_first).to eq(true)
      expect(@loader.frames[1].duration).to eq(0.05)
    end

    it 'loads an animation spec from an XML file.' do
      test_name = 'skip_first_test'
      source = "#{@source_dir}/#{test_name}.xml"
      destination = "#{@destination_dir}/#{test_name}_xml.svg"

      @loader.add_frame_from_file(source)
      @loader.save_svg(destination)
      @loader.reset
      @loader.add_frame_from_file(destination)

      expect(@loader.frames.size).to eq(24)
      expect(@loader.width).to eq('64px')
      expect(@loader.height).to eq('64px')
      expect(@loader.loops).to eq(0)
      expect(@loader.skip_first).to eq(true)
      expect(@loader.frames[1].duration).to eq(0.05)
    end
  end

  describe 'creating an animated SVG file from a JPEG files.' do
    before(:all) do
      @image_name = 'jpeg_test'
      @source_dir = "#{SPEC_SOURCE_DIR}/#{@image_name}"
      @destination_dir = SPEC_TEMP_DIR
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'loads frames.' do
      test_name = 'jpeg_test'
      @loader.add_frame_from_file("#{@source_dir}/*.jpg")
      expect(@loader.frames.size).to eq(34)
      @loader.frames.each do |frame|
        expect(frame.duration.instance_of?(Float)).to eq(true)
        expect(frame.width).to eq('64px')
        expect(frame.height).to eq('64px')
        expect(frame.surfaces).not_to be_nil
        expect(frame.surfaces).not_to be_empty
        expect(frame.surfaces.to_s.length).not_to eq(1)
        expect(frame.namespaces).not_to be_empty
      end
      write_size = @loader.save_svg("#{@destination_dir}/#{test_name}.svg")
      expect(write_size).not_to eq(0)
      write_size = @loader.save_apng("#{@destination_dir}/#{test_name}.png")
      expect(write_size).not_to eq(0)
    end
  end

  describe 'creating an animated SVG file from a GIF files.' do
    before(:all) do
      @image_name = 'apngasm'
      @source = "#{SPEC_SOURCE_DIR}/#{@image_name}.gif"
      @destination_dir = SPEC_TEMP_DIR
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'loads frames / saves to SVG and PNG' do
      test_name = 'gif_test'
      @loader.add_frame_from_file(@source)
      expect(@loader.frames.size).to eq(34)
      @loader.frames.each do |frame|
        expect(frame.duration.instance_of?(Float)).to eq(true)
        expect(frame.width).to eq('64px')
        expect(frame.height).to eq('64px')
        expect(frame.surfaces).not_to be_nil
        expect(frame.surfaces).not_to be_empty
        expect(frame.surfaces.to_s.length).not_to eq(1)
        expect(frame.namespaces).not_to be_empty
      end
      write_size = @loader.save_svg("#{@destination_dir}/#{test_name}.svg")
      expect(write_size).not_to eq(0)
      write_size = @loader.save_apng("#{@destination_dir}/#{test_name}.png")
      expect(write_size).not_to eq(0)
    end
  end
end
