platform :ios, '8.0'

target 'RxTodo' do
  use_frameworks!

  # Architecture
  pod 'ReactorKit'

  # Rx
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxOptional'
  pod 'RxViewController'

  # UI
  pod 'SnapKit'
  pod 'ManualLayout'

  # Misc.
  pod 'Then'
  pod 'ReusableKit'
  pod 'CGFloatLiteral'
  pod 'URLNavigator'

  # Testing
  target 'RxTodoTests' do
    pod 'RxTest'
    pod 'RxExpect'
    pod 'RxOptional'
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.2'
    end
  end
end
