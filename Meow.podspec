Pod::Spec.new do |s|
  s.ios.deployment_target = '11.0'
  s.name             = 'Meow'
  s.version          = '2.0.1'
  s.summary          = 'A pure swift MongoDB ORM built on MongoKitten Mobile'

  s.description      = <<-DESC
A codable ORM for MongoDB embedded and server setups.
                       DESC

  s.swift_version = '4.2'
  s.homepage         = 'https://github.com/OpenKitten/Meow'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Joannis Orlandos' => 'joannis@orlandos.nl', 'Robbert Brandsma' => 'i@robbertbrandsma.nl' }
  s.source           = { :git => 'https://github.com/OpenKitten/Meow.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/joannisorlandos'

  s.dependency     'MongoKitten', '>= 5.1.3'
  s.source_files = 'Sources/Meow/**/*'
end
