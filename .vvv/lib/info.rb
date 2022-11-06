module VVV
  class Info
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
  end
end
