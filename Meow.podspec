#
# Be sure to run `pod lib lint Rockstar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.ios.deployment_target = '12.0'
  s.name             = 'Meow'
  s.version          = '5.1.2'
  s.summary          = 'A pure swift MongoDB ORM built on MongoKitten Mobile'

  s.description      = <<-DESC
A codable ORM for MongoDB embedded and server setups.
                       DESC

  s.swift_version = '4.2'
  s.homepage         = 'https://github.com/OpenKitten/Meow'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Joannis Orlandos' => 'joannis@orlandos.nl', 'Robbert Brandsma' => 'i@robbertbrandsma.nl' }
  s.source           = { :git => 'https://github.com/OpenKitten/MongoKitten.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/joannisorlandos'

  s.dependency     'MongoKitten', '>= 5.1.2'
  s.source_files = 'Sources/Meow/**/*'
end
