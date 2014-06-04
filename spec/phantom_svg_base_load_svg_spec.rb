require 'phantom/svg'

# Set Current directory.
Dir.chdir(File.dirname(__FILE__))

# Parameter.
SOURCE = 'images/ninja.svg'

# Test start.
describe Phantom::SVG::Base, 'when load no animation svg (SOURCE: \'' + SOURCE + '\')' do
  before do
    @loader = Phantom::SVG::Base.new(SOURCE)
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
  end
end
