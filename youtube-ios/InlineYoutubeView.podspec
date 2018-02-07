Pod::Spec.new do |s|
  s.name             = 'InlineYoutubeView'
  s.version          = '1.0.2'
  s.summary          = 'Play inline youtube videos'

  s.description      = <<-DESC
  Helper library for iOS developers who want to play YouTube videos in
  their iOS apps with the iframe player API.
  This library allows iOS developers to quickly embed YouTube videos within
  their applications via a custom subclass called InlineYoutubeView which is modification of the original YTPlayerView by youtube.
  This library provides:
  * A managed WKWebView instance that loads the HTML code for the iframe player
  * Objective-C wrapper functions for the JavaScript Player API
  * YTPlayerViewDelegate for handling YouTube player state changes natively in
  your Objective-C code
                    DESC

  s.homepage         = 'https://github.com/flipkart-incubator/inline-youtube-view'
  s.license          = { :type => 'Apache, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'shubhankaryash' => 'shubhankar.yash@flipkart.com' }
  s.source           = { :git => 'https://github.com/flipkart-incubator/inline-youtube-view.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'
  s.source_files = 'InlineYoutubeView/Classes/**/*'
end
