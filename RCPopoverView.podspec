Pod::Spec.new do |s|
  s.name     = 'RCPopoverView'
  s.version  = '0.2'
  s.platform = :ios
  s.license  = 'MIT'
  s.summary  = 'An easy to use class to present any UIView as a popover with fade and slide animations.'
  s.homepage = 'http://robinchou.com'
  s.author   = { 'Robin Chou' => 'hello@robinchou.com' }
  s.source   = { :git => 'https://github.com/chourobin/RCPopoverView.git', :tag => s.version.to_s }
  s.description = 'RCPopoverView is an easy to use cocoa class that can display a generic or custom UIView with fade and slide animations.'
  s.source_files = 'RCPopoverView/*.{h,m}'
  s.framework    = 'QuartzCore'
  s.requires_arc = true
end