#
# Be sure to run `pod lib lint IInkUIRefImpl.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MyScriptInteractiveInk-UIReferenceImplementation'
  s.version          = '1.3.2'
  s.summary          = 'InteractiveInkUIReferenceImplementation : IInkRuntime UI interfaces reference implementation for iOS platforms.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Interactive Ink extends digital ink to allow users to more intuitively create, interact with, and share content in digital form.
Handwritten text, mathematical equations or even diagrams are interpreted in real-time to be editable via simple gestures, responsive and easy to convert to a neat output.
This pod speeds up the integration of those riche features into your application.
Visit https://developer.myscript.com/ to create your MyScript Developer account and start using the library.
                       DESC

  s.homepage         = 'http://www.myscript.com'
  s.documentation_url= 'https://developer.myscript.com/docs/interactive-ink/latest/ios/'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'MyScript' => 'dev.support@myscript.com' }
  s.source           = { :git => 'https://github.com/MyScript/interactive-ink-examples-ios', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.1'
  s.swift_version         = '4.2'

  s.header_dir = 'IInkUIReferenceImplementation'

  s.source_files = 'IInkUIReferenceImplementation/Classes/**/*'
  s.preserve_paths = 'IInkUIReferenceImplementation/Classes/**'
  s.dependency 'MyScriptInteractiveInk-Runtime', '1.3.2'
end
