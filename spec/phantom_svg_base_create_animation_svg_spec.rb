require 'phantom/svg'

# Set Current directory.
Dir::chdir(File.dirname(__FILE__))

# Parameter.
Source = "images/stuck_out_tongue/*.svg"
Destination = "stuck_out_tongue.svg"

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

  after do
  end
end
