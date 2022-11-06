module VVV
  class Bootstrap
    def self.show_logo?
      return false if ENV['VVV_SKIP_LOGO']

      return true if %w[up resume status provision reload].include? ARGV[0]

      false
    end

    def self.show_sudo_bear?
      return true if !Vagrant::Util::Platform.windows? && Process.uid == 0

      false
    end
  end
end
