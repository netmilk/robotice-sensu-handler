module Sensu
  module Plugin
    module Utils
      def config_files
        if ENV['SENSU_CONFIG_FILES']
          ENV['SENSU_CONFIG_FILES'].split(':')
        else
          ['/etc/sensu/config.json'] + Dir['/etc/sensu/conf.d/*.json']
        end
      end
    end
  end
end