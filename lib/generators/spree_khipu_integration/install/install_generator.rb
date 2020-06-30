module SpreeKhipuIntegration
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def add_initializer
        copy_file "khipu.rb", "config/initializers/khipu.rb"
      end
    end
  end
end
