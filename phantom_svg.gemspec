Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = 'phantom_svg'
  s.version       = '1.2.1'
  s.license       = 'LGPL-3'
  s.summary       = 'Hight end SVG manipulation tools for Ruby'
  s.description   = 'Hight end SVG manipulation tools for Ruby.\n' \
                    'Includes chained keyframe generation, (A)PNG conversion and more.'
  s.authors      = ['Rika Yoshida', 'Naoki Iwakawa', 'Rei Kagetsuki']
  s.email        = 'info@genshin.org'
  s.homepage     = 'http://github.com/Genshin/phantom_svg'

  s.files = `git ls-files`.split($RS)
  s.test_files = s.files.grep(/^spec\//)
  s.require_path = 'lib'

  s.requirements << 'libapngasm'

  s.add_dependency 'cairo', '~> 1.14', '~> 1.14.3'
  s.add_dependency 'rapngasm', '~> 3.2', '~> 3.2.0'
  s.add_dependency 'rsvg2', '~> 3.0', '~> 3.0.7'
  s.add_dependency 'rmagick', '~> 2.15', '~> 2.15.4'
end
