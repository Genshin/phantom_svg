module Phantom
  module SVG
    attr_accessor :frames
    def initialize(path = nil)
      load_file(path) if path
    end

    def load_file(path)
      # TODO: もしSVGならそのまま開く
      # TODO: もしフレームがあればframesに入れる
    end

    def load_raster(path)
      # TODO: pngをsurfaceに読み込む
      # TODO: もしAPNGなら分解してframeにする
    end

    # Creates a blank frame when no arguments are passed
    # Takes another Phantom::SVG object or file path
    def add_frame(frame = nil)
      # TODO もしnilなら空のフレームをframesに追加
      # TODO もしPhantom::SVGなら情報をframeオブジェに入れてframesに追加
      # TODO もしファイルパスなら読み込む
    end

    def save(path)
      # SVG出力
    end

    def save_rasterized(path)
      # APNGを出力
    end
  end
end
