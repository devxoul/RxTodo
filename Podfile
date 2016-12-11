platform :ios, '8.0'

target 'RxTodo' do
  use_frameworks!

  # Rx
  pod 'RxSwift', '~> 3.0'
  pod 'RxCocoa', '~> 3.0'
  pod 'RxDataSources', '~> 1.0'
  pod 'RxOptional', '~> 3.1'

  # UI
  pod 'SnapKit', '~> 3.0'
  pod 'ManualLayout', '~> 1.3'

  # Misc.
  pod 'Then', '~> 2.1'
  pod 'ReusableKit', '~> 1.1'
  pod 'CGFloatLiteral', '~> 0.2'

  # Testing
  target 'RxTodoTests' do
    pod 'RxTest', '~> 3.0'
    pod 'RxExpect', '~> 0.2'
    pod 'RxOptional', '~> 3.1'
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
