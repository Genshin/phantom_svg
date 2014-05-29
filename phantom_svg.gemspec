Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = 'Phantom SVG'
  s.version       = '0.0.1'
  s.license       = 'LGPL-3.0'
  s.summary       = 'Hight End SVG manipulation tools for Ruby'
  s.description   = 'Hight End SVG manipulation tools for Ruby.\n' +
                    'Includes chained keyframe generation, (A)PNG conversion and more.'
  s.authors      = ['Rika Yoshida', 'Rei Kagetsuki', 'Naoki Iwakawa']
  s.email        = 'info@genshin.org'
  s.homepage     = 'http://github.com/Genshin/phantom_svg'

  s.required_ruby_version = '~> 2.0.0'

  s.files = `git ls-files`.split($RS)
  s.test_files = s.files.grep(/^spec\//)
  s.require_path = 'lib'

  s.requirements << 'libapngasm'

  s.add_dependency 'cairo', '~> 1.12'
  s.add_dependency 'rapngasm', '~> 3.1'
  s.add_dependency 'gdk3', '~> 2.2'
  s.add_dependency 'rsvg2', '~> 2.2'
  s.add_dependency 'nokogiri', '~> 1.6'
end
