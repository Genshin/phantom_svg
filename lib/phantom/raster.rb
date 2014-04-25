require 'rapngasm'
require_relative 'svg/frame.rb'

module Phantom
  module Raster
    def load_raster(path)
      # TODO: pngをsurfaceに読み込む
      surface = Cairo::ImageSurface.from_png(path)
      
      # TODO: もしAPNGなら分解してframeにする
      # disassemble(path) if ...

    end

    def disassemble(path)
      apngasm = APNGAsm.new
      png_frames = apngasm.disassemble(path)
      png_frames.each do |frame|
        # TODO フレーム作成
        # @frames << Phantom::SVG::Frame.new()
      end
    end

    def save_rasterized(path)
      # APNGを出力
      apngasm = APNGAsm.new
      # TODO フレーム追加
      apngasm.assemble(path)
    end
  end
end