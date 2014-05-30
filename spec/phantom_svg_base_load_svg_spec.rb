require 'phantom/svg'

# Set Current directory.
Dir::chdir(File.dirname(__FILE__))
SourcePath = "images/ninja.svg"

# Test start.
describe Phantom::SVG::Base, "when load " + SourcePath do
  before do
    @loader = Phantom::SVG::Base.new(SourcePath)
  end

  it "frames should have 1 frames." do
    @loader.frames.should have(1).frames
  end

  it "frame duration should equal 1." do
    @loader.frames[0].duration.should eql(1)
  end

  it "frame surface should not be nil." do
    @loader.frames[0].surface.should_not be_nil
  end

  it "frame surface should not be empty." do
    @loader.frames[0].surface.should_not be_empty
  end

  it "frame width should equal \"64px\"." do
    @loader.frames[0].width.should eql("64px")
  end

  it "frame height should equal \"64px\"." do
    @loader.frames[0].height.should eql("64px")
  end

  it "frame namespaces should not be empty." do
    @loader.frames[0].namespaces.should_not be_empty
  end

  after do
  end
end
