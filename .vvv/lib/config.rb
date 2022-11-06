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

    require 'yaml'

    def initialize
      @config = YAML.load_file(CONFIG_FILE)
      lint
    end

    def values
      @config
    end

    def lint
      # If 'hosts' isn't an array, redefine it as such
      @config['hosts'] = ['vvv.test'] unless @config['hosts'].is_a? Array

      @config['sites'].each do |site, args|
        # If the site's value is a string, treat it as the repo value
        if @config['sites'][site].is_a? String
          @config['sites'][site] = { 'repo': args }
        end

        # If the site's args aren't defined as a Hash already, redefine it as such
        @config['sites'][site] = {} unless @config['sites'][site].is_a? Hash

        merge_site_defaults(site)
        process_hosts_for_site(site)
      end
    end

    private

    def process_hosts_for_site(site)
      unless @config['sites'][site]['skip_provisioning']
        # Find vvv-hosts files and add their lines to the @config hash
        site_host_paths = Dir.glob("#{@config['sites'][site]['local_dir']}/*/vvv-hosts")
        site_host_paths.each do |path|
          lines = File.readlines(path).map(&:chomp).grep(/\A[^#]/)
          lines.each do |l|
            @config['sites'][site]['hosts'] << l
          end
        end

        # Add the site's hosts to the 'global' hosts array
        if @config['sites'][site]['hosts'].is_a? Array
          @config['hosts'] += @config['sites'][site]['hosts']
        else
          @config['hosts'] += ["#{site}.test"]
        end
        @config['sites'][site].delete('hosts')
      end
    end

    def merge_site_defaults(site)
      # Merge the defaults with the currently defined site args
      @config['sites'][site] = site_defaults(site).merge(@config['sites'][site])
    end

    def site_defaults(site)
      {
        'repo'              => false,
        'vm_dir'            => "/srv/www/#{site}",
        'local_dir'         => File.join(VVV::Info.vagrant_dir, 'www', site),
        'branch'            => 'master',
        'skip_provisioning' => false,
        'allow_customfile'  => false,
        'nginx_upstream'    => 'php',
        'hosts'             => []
      }
    end
  end
end
