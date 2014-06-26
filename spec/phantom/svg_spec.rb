require 'phantom/svg'

# Set Current directory.
Dir.chdir(SPEC_ROOT_DIR)

describe Phantom::SVG::Base do

  describe 'when load no animation svg' do
    before(:all) do
      @emoji_name = 'ninja'
      @source = SPEC_SOURCE_DIR + '/' + @emoji_name + '.svg'
    end

    before do
      @loader = Phantom::SVG::Base.new(@source)
    end

    it 'frames vector size equal 1.' do
      expect(@loader.frames.size).to eq(1)
    end

    it 'frame duration equal 0.1.' do
      expect(@loader.frames[0].duration).to eq(0.1)
    end

    it 'frame surface is not nil.' do
      expect(@loader.frames[0].surface).not_to be_nil
    end

    it 'frame surface is not empty.' do
      expect(@loader.frames[0].surface).not_to be_empty
    end

    it 'frame width equal \'64px\'.' do
      expect(@loader.frames[0].width).to eq('64px')
    end

    it 'frame height equal \'64px\'.' do
      expect(@loader.frames[0].height).to eq('64px')
    end

    it 'frame namespaces is not empty.' do
      expect(@loader.frames[0].namespaces).not_to be_empty
    end

    after do
      # nop
    end
  end

  describe 'when create animation svg' do
    before(:all) do
      @emoji_name = 'stuck_out_tongue'
      @source = SPEC_SOURCE_DIR + '/' + @emoji_name + '/*.svg'
      @destination_dir = SPEC_TEMP_DIR + '/' + @emoji_name + '/'
      @destination = @destination_dir + @emoji_name + '.svg'
      FileUtils.mkdir_p(@destination_dir)
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'save file size is not equal 0.' do
      @loader.add_frame_from_file(@source)
      write_size = @loader.save_svg(@destination)
      expect(write_size).not_to eq(0)
    end

    it 'animation svg file frames size equal 12.' do
      @loader.add_frame_from_file(@destination)
      expect(@loader.frames.size).to eq(12)
    end

    it 'frame surface length is not equal 1.' do
      @loader.add_frame_from_file(@destination)

      range = 0..(@loader.frames.length - 1)
      range.each do |i|
        frame = @loader.frames[i]
        expect(frame.surface.to_s.length).not_to eq(1)

        @loader.save_svg_frame(@destination_dir + i.to_s + '.svg', frame)
      end
    end

    after do
      # nop
    end
  end

  describe 'when create animation svg from file of json' do
    before(:all) do
      @emoji_name = 'stuck_out_tongue'
      @source_dir = SPEC_SOURCE_DIR + '/' + @emoji_name
      @destination_dir = SPEC_TEMP_DIR
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'load frames from "test1.json".' do
      test_name = 'test1'
      @loader.add_frame_from_file(@source_dir + '/' + test_name + '.json')
      expect(@loader.frames.size).to eq(12)
      @loader.frames.each do |frame|
        expect(frame.duration.instance_of?(Float)).to eq(true)
        expect(frame.width).to eq('64px')
        expect(frame.height).to eq('64px')
        expect(frame.surface).not_to be_nil
        expect(frame.surface).not_to be_empty
        expect(frame.surface.to_s.length).not_to eq(1)
        expect(frame.namespaces).not_to be_empty
      end
      write_size = @loader.save_svg(@destination_dir + '/json_' + test_name + '.svg')
      expect(write_size).not_to eq(0)
    end

    it 'load frames from "test2.json".' do
      test_name = 'test2'
      @loader.add_frame_from_file(@source_dir + '/' + test_name + '.json')
      expect(@loader.frames.size).to eq(12)
      @loader.frames.each do |frame|
        expect(frame.duration.instance_of?(Float)).to eq(true)
        expect(frame.width).to eq('64px')
        expect(frame.height).to eq('64px')
        expect(frame.surface).not_to be_nil
        expect(frame.surface).not_to be_empty
        expect(frame.surface.to_s.length).not_to eq(1)
        expect(frame.namespaces).not_to be_empty
      end
      write_size = @loader.save_svg(@destination_dir + '/json_' + test_name + '.svg')
      expect(write_size).not_to eq(0)
    end
  end

  describe 'when create animation svg from file of xml' do
    before(:all) do
      @emoji_name = 'stuck_out_tongue'
      @source_dir = SPEC_SOURCE_DIR + '/' + @emoji_name
      @destination_dir = SPEC_TEMP_DIR
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'load frames from "test1.xml".' do
      test_name = 'test1'
      @loader.add_frame_from_file(@source_dir + '/' + test_name + '.xml')
      expect(@loader.frames.size).to eq(12)
      @loader.frames.each do |frame|
        expect(frame.duration.instance_of?(Float)).to eq(true)
        expect(frame.width).to eq('64px')
        expect(frame.height).to eq('64px')
        expect(frame.surface).not_to be_nil
        expect(frame.surface).not_to be_empty
        expect(frame.surface.to_s.length).not_to eq(1)
        expect(frame.namespaces).not_to be_empty
      end
      write_size = @loader.save_svg(@destination_dir + '/xml_' + test_name + '.svg')
      expect(write_size).not_to eq(0)
    end

    it 'load frames from "test2.xml".' do
      test_name = 'test2'
      @loader.add_frame_from_file(@source_dir + '/' + test_name + '.xml')
      expect(@loader.frames.size).to eq(12)
      @loader.frames.each do |frame|
        expect(frame.duration.instance_of?(Float)).to eq(true)
        expect(frame.width).to eq('64px')
        expect(frame.height).to eq('64px')
        expect(frame.surface).not_to be_nil
        expect(frame.surface).not_to be_empty
        expect(frame.surface.to_s.length).not_to eq(1)
        expect(frame.namespaces).not_to be_empty
      end
      write_size = @loader.save_svg(@destination_dir + '/xml_' + test_name + '.svg')
      expect(write_size).not_to eq(0)
    end
  end

  describe 'when convert animation svg to apng' do
    before(:all) do
      @emoji_name = 'stuck_out_tongue'
      @source = SPEC_SOURCE_DIR + '/' + @emoji_name + '/*.svg'
      @destination = SPEC_TEMP_DIR + '/svg2apng.png'
    end

    before do
      options = { duration: 0.5 }
      @loader = Phantom::SVG::Base.new(@source, options)
    end

    it 'succeeded convert.' do
      expect(@loader.frames.size).to eq(12)
      is_succeeded = @loader.save_apng(@destination)
      expect(is_succeeded).to eq(true)
    end
  end

  describe 'when convert apng to animation svg' do
    before(:all) do
      @apng_name = 'apngasm'
      @source = SPEC_SOURCE_DIR + '/' + @apng_name + '.png'
      @destination_dir = SPEC_TEMP_DIR + '/' + @apng_name
      @destination = @destination_dir + '/' + @apng_name + '.svg'
      FileUtils.mkdir_p(@destination_dir)
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'load apng and save animation svg.' do
      @loader.add_frame_from_file(@source)
      expect(@loader.frames.size).to eq(34)

      write_size = @loader.save_svg(@destination)
      expect(write_size).not_to eq(0)

      range = 0..(@loader.frames.length - 1)
      range.each do |i|
        frame = @loader.frames[i]
        write_size = @loader.save_svg_frame(@destination_dir + '/' + i.to_s + '.svg', frame)
        expect(write_size).not_to eq(0)
      end
    end

    it 'new svg load test.' do
      @loader.add_frame_from_file(@destination)
      expect(@loader.frames.size).to eq(34)

      @loader.frames.each do |frame|
        expect(frame.duration).to eq(0.1)
        expect(frame.width).to eq(64)
        expect(frame.height).to eq(64)
        expect(frame.surface.to_s.length).not_to eq(0)
        expect(frame.namespaces.length).not_to eq(0)
      end
    end
  end

  describe 'when loops is 2' do
    before(:all) do
      @emoji_name = 'stuck_out_tongue'
      @source = SPEC_SOURCE_DIR + '/' + @emoji_name + '/*.svg'
      @destination_dir = SPEC_TEMP_DIR
      @destination_svg = @destination_dir + '/loops_test.svg'
      @destination_png = @destination_dir + '/loops_test.png'
    end

    before do
      @loader = Phantom::SVG::Base.new
    end

    it 'can save animation svg.' do
      @loader.add_frame_from_file(@source)
      @loader.loops = 2

      write_size = @loader.save_svg(@destination_svg)
      expect(write_size).not_to eq(0)
    end

    it 'saved animation svg is succeeded.' do
      @loader.add_frame_from_file(@destination_svg)

      expect(@loader.frames.size).to eq(12)
      expect(@loader.width).to eq('64px')
      expect(@loader.height).to eq('64px')
      expect(@loader.loops).to eq(2)
    end
  end

  describe 'skip_first test' do
    it 'todo' do
      expect(0).to eq(1)
    end
  end
end
