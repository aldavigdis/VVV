module VVV
  class Info
    require 'vagrant/util/platform'

    def self.vagrant_dir
      File.expand_path('.')
    end

    def self.branch
      `git --git-dir="#{vagrant_dir}/.git" \
      --work-tree="#{vagrant_dir}" rev-parse \
      --abbrev-ref HEAD`.chomp
    end

    def self.commit
      `git --git-dir="#{vagrant_dir}/.git" \
      --work-tree="#{vagrant_dir}" rev-parse \
      --short HEAD`.chomp
    end

    def self.version
      version_file_path = "#{vagrant_dir}/version"
      return '?' unless File.file? version_file_path

      File.open(version_file_path, 'r').read.chomp
    end

    def self.zip_or_git
      return 'zip' unless File.directory?("#{vagrant_dir}/.git")

      'git'
    end

    def self.version_control
      return 'zip-no-vcs' if zip_or_git == 'zip'

      "#{zip_or_git}::#{branch}(#{commit})"
    end

    def self.environment
      "v#{version} Ruby:#{RUBY_VERSION}, Path:\"#{vagrant_dir}\""
    end

    def self.platform
      self.platform_array.join(' ')
    end

    def self.platform_array
      config = VVV::Config.new.values

      platform = [Vagrant::Util::Platform.platform]

      if Vagrant::Util::Platform.windows?
        # Windows specific checks
        platform << 'Windows'
        platform << 'wsl' if Vagrant::Util::Platform.wsl?
        platform << 'msys' if Vagrant::Util::Platform.msys?
        platform << 'cygwin' if Vagrant::Util::Platform.cygwin?
        if Vagrant::Util::Platform.windows_hyperv_enabled?
          platform << 'HyperV-Enabled'
        end
        if Vagrant::Util::Platform.windows_hyperv_admin?
          platform << 'HyperV-Admin'
        end
        if Vagrant::Util::Platform.windows_admin?
          platform << 'HasWinAdminPriv'
        end
        unless Vagrant::Util::Platform.windows_admin?
          platform << 'missingWinAdminPriv'
        end
      else
        # Non-Windows specific checks
        platform << "shell: #{ENV['SHELL']}" if ENV['SHELL']
        platform << 'systemd' if Vagrant::Util::Platform.systemd?
      end

      (vagrant_global_plugins + vagrant_local_plugins).each do |p|
        platform << p
      end

      if Vagrant::Util::Platform.fs_case_sensitive?
        platform << 'CaseSensitiveFS'
      end

      # Check if the terminal supports colors.
      # This seems to be faulty.
      unless Vagrant::Util::Platform.terminal_supports_colors?
        platform << 'monochrome-terminal'
      end

      if config['vm_config']['wordcamp_contributor_day_box'] == true
        platform << 'contributor_day_box'
      end

      if config['vm_config'].key?('box')
        platform << "box_override:#{config['vm_config']['box']}"
        # Todo: Add info box with the following text:
        # Custom Box: Box overridden via config/config.yml,
        # this won't take effect until a destroy + reprovision happens
      end

      if config['general'].key?('db_share_type')
        if config['general']['db_share_type'] == true
          platform << 'shared_db_folder_enabled'
        else
          platform << 'shared_db_folder_disabled'
        end
      else
        platform << 'shared_db_folder_default'
      end

      platform
    end

    def self.vagrant_local_plugins
      json_file_path = File.join(vagrant_dir, '/.vagrant/plugins.json')
      return [] unless File.file?(json_file_path)

      json_file = File.read(json_file_path)
      json_hash = JSON.parse(json_file)

      json_hash['installed'].keys
    end

    def self.vagrant_global_plugins
      json_file_path = File.join(Dir.home, '/.vagrant.d/plugins.json')
      return [] unless File.file?(json_file_path)

      json_file = File.read(json_file_path)
      json_hash = JSON.parse(json_file)

      json_hash['installed'].keys
    end
  end
end
