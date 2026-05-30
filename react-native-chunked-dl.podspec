require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

Pod::Spec.new do |s|
  s.name         = "react-native-chunked-dl"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  # `min_ios_version_supported` / `min_tvos_version_supported` come from
  # react_native_pods.rb. Fall back to the historical hardcoded values when
  # this podspec is evaluated outside a React Native Podfile context.
  s.platforms    = {
    :ios  => (defined?(min_ios_version_supported) ? min_ios_version_supported : "12.4"),
    :tvos => (defined?(min_tvos_version_supported) ? min_tvos_version_supported : "12.4")
  }
  s.source       = { :git => "https://github.com/Spicy-Sparks/react-native-chunked-dl.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"

  # Use install_modules_dependencies when available (React Native >= 0.71).
  # On the New Architecture this wires up the React Native dependencies the
  # right way for the installed RN version — including the PREBUILT
  # ReactNativeDependencies (folly/fmt/glog) on RN >= 0.85. The old manual
  # `s.dependency "RCT-Folly"` path force-built fmt FROM SOURCE, which fails
  # to compile under Xcode 26 / Swift 6 ("call to consteval function
  # fmt::basic_format_string ... is not a constant expression"). Letting the
  # helper resolve the deps fixes that build break.
  # See https://github.com/facebook/react-native/blob/main/packages/react-native/scripts/cocoapods/new_architecture.rb
  if respond_to?(:install_modules_dependencies, true)
    install_modules_dependencies(s)
  else
    s.dependency "React-Core"

    # Don't install the dependencies when we run `pod install` in the old architecture.
    if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
      s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
      s.pod_target_xcconfig    = {
          "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
          "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1",
          "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
      }
      s.dependency "React-Codegen"
      s.dependency "RCT-Folly"
      s.dependency "RCTRequired"
      s.dependency "RCTTypeSafety"
      s.dependency "ReactCommon/turbomodule/core"
    end
  end
end
