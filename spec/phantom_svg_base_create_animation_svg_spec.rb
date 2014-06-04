require 'phantom/svg'

# Parameter.
SOURCE = 'images/stuck_out_tongue/*.svg'
DESTINATION_DIR = 'tmp/stuck_out_tongue/'
DESTINATION = DESTINATION_DIR + 'stuck_out_tongue.svg'

# Set Current directory.
Dir.chdir(File.dirname(__FILE__))

FileUtils.mkdir_p(DESTINATION_DIR)

# Test start.
describe Phantom::SVG::Base, 'when create animation svg (SOURCE: \'' + SOURCE + '\')' do
  before do
    @loader = Phantom::SVG::Base.new
  end

  it 'save file size is not equal 0.' do
    files = Dir.glob(SOURCE).sort_by { |k| k[/\d+/].to_i }
    files.each do |file|
      @loader.create_frame(file)
    end
    write_size = @loader.save(DESTINATION)
    expect(write_size).not_to eq(0)
  end

  it 'animation svg file frames size equal 12.' do
    @loader.load_file(DESTINATION)
    expect(@loader.frames.size).to eq(12)
  end

  it 'frame surface length is not equal 1.' do
    @loader.load_file(DESTINATION)

    range = 0..(@loader.frames.length - 1)
    range.each do |i|
      frame = @loader.frames[i]
      expect(frame.surface.to_s.length).not_to eq(1)

      @loader.save_frame(DestinationDir + i.to_s + '.svg', frame)
    end
  end

  after do
  end
end
