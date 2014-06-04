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

  it 'save file size should not equal 0' do
    files = Dir.glob(SOURCE).sort_by { |k| k[/\d+/].to_i }
    files.each do |file|
      @loader.create_frame(file)
    end

    @loader.save(DESTINATION).should_not eql(0)
  end

  it 'animation svg file should have 12 frames' do
    @loader.load_file(DESTINATION)
    @loader.frames.should have(12).frames
  end

  it 'frame surface length should not equal 1' do
    @loader.load_file(DESTINATION)

    range = 0..(@loader.frames.length - 1)
    range.each do |i|
      frame = @loader.frames[i]
      frame.surface.to_s.length.should_not eql(1)

      @loader.save_frame(DestinationDir + i.to_s + '.svg', frame)
    end
  end

  after do
  end
end
