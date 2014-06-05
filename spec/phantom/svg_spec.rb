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

    it 'frame duration equal 1.' do
      expect(@loader.frames[0].duration).to eq(1)
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
      files = Dir.glob(@source).sort_by { |k| k[/\d+/].to_i }
      files.each do |file|
        @loader.add_frame_from_file(file)
      end
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

        @loader.save_png_frame(@destination_dir + i.to_s + '.svg', frame)
      end
    end

    after do
      # nop
    end
  end

  describe 'when create animation svg from file of json and xml' do
    it 'todo' do
      expect(0).to eq(1)
    end
  end

  describe 'when convert animation svg to apng' do
    it 'todo' do
      expect(0).to eq(1)
    end
  end

  describe 'when convert apng to animation svg' do
    it 'todo' do
      expect(0).to eq(1)
    end
  end
end
