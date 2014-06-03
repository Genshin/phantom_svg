require 'phantom/svg'

# Parameter.
Source = "images/stuck_out_tongue/*.svg"
DestinationDir = "tmp/stuck_out_tongue/"
Destination = DestinationDir + "stuck_out_tongue.svg"

# Set Current directory.
Dir::chdir(File.dirname(__FILE__))

if File::exist?(DestinationDir) == false then
  Dir::mkdir(DestinationDir)
end

# Test start.
describe Phantom::SVG::Base, "when create animation svg (Source: \"" + Source + "\")" do
  before do
    @loader = Phantom::SVG::Base.new()
  end

  it "save file size should not equal 0" do
    files = Dir::glob(Source).sort_by { |k| k[/\d+/].to_i }
    files.each do |file|
      @loader.create_frame(file)
    end

    @loader.save(Destination).should_not eql(0)
  end

  it "animation svg file should have 12 frames" do
    @loader.load_file(Destination)
    @loader.frames.should have(12).frames
  end

  it "frame surface length should not equal 1" do
    @loader.load_file(Destination)

    for i in 0..(@loader.frames.length-1) do
      frame = @loader.frames[i]
      frame.surface.to_s.length.should_not eql(1)

      @loader.save_frame(DestinationDir + i.to_s + ".svg", frame)
    end
  end

  after do
  end
end
