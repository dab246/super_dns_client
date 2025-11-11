#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint super_dns_client.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'super_dns_client'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for resolving SRV records using system DNS servers.'
  s.description      = <<-DESC
super_dns_client provides DNS SRV lookup capabilities using the system DNS resolvers
on Android, iOS, macOS, and desktop platforms.
  DESC
  s.homepage         = 'https://github.com/dab246/super_dns_client'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dat Vu' => 'datx1995@gmail.com' }
  s.source           = { :path => '.' }

  s.source_files = 'Classes/**/*.{h,m,swift}'
  s.dependency       'Flutter'
  s.platform         = :ios, '12.0'
  s.swift_version    = '5.0'

  # Flutter.framework does not contain a i386 slice.
    s.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES',
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
      'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include',
      'OTHER_LDFLAGS' => '-lresolv'
    }

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = { 'super_dns_client_privacy' => ['Resources/PrivacyInfo.xcprivacy'] }
end
