module VVV
  class Config
    CONFIG_FILE = File.join(
      VVV::Info.vagrant_dir, 'config/config.yml'
    ).freeze

    DEFAULT_CONFIG_FILE = File.join(
      VVV::Info.vagrant_dir, 'config/default-config.yml'
    ).freeze

    OLD_CONFIG_FILE = File.join(
      VVV::Info.vagrant_dir, 'vvv-custom.yml'
    ).freeze

    def self.values
      YAML.load_file(CONFIG_FILE)
    end
  end
end
