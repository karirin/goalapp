# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Goal' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Goal
  pod 'FSCalendar'  #追加
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.4'
               end
          end
   end
end
