module VVV
  class SplashScreens
    C_RESET    = "\033[0m"
    C_RED      = "\033[38;5;9m"
    C_CYAN     = "\033[38;5;6m"
    C_GREEN    = "\033[1;38;5;2m"
    C_BLUE     = "\033[38;5;4m"
    C_PURPLE   = "\033[38;5;5m"
    C_DOCS     = "\033[0m"
    C_YELLOW   = "\033[38;5;3m"
    C_YELLOW_U = "\033[4;38;5;3m"

    require 'pathname'

    def self.v_logo
      v_logo_lines.each do |l|
        puts l
      end
      nil
    end

    def self.v_logo_with_info
      v_logo_lines.each_with_index do |l,i|
        case i
        when 1
          puts "#{l} #{C_PURPLE}#{VVV::Info.environment}#{C_RESET}"
        when 2
          puts "#{l} #{C_CYAN}#{VVV::Info.version_control}#{C_RESET}"
        else
          puts l
        end
      end
      nil
    end

    def self.warning_sudo_bear
      render_file('../assets/bear_warning_sudo.txt', C_RED)
      nil
    end

    def self.info_config_migration(from, to)
      from_relative = relative_path(from)
      to_relative   = relative_path(to)

      message = "#{C_YELLOW}Migrating #{C_RED}#{from_relative}#{C_YELLOW} to "\
                "#{C_GREEN}#{to_relative}\n"\
                "#{C_YELLOW}IMPORTANT NOTE: Make all modifications to "\
                "#{C_GREEN}#{to_relative}#{C_YELLOW}.#{C_RESET}\n\n"
      puts message
      nil
    end

    def self.info_sql_database_migration(from, to)
      from_relative  = relative_path(from)
      to_relative    = relative_path(to)

      puts "#{C_YELLOW}Moving SQL database backup directory from "\
           "#{C_RED}#{from_relative}#{C_YELLOW} to "\
           "#{C_GREEN}#{to_relative}#{C_RESET}\n\n"
      nil
    end

    private

    def self.relative_path(path)
      vagrant_dir_path = Pathname.new(VVV::Info.vagrant_dir)
      absolute_path    = Pathname.new(path)

      absolute_path.relative_path_from(vagrant_dir_path)
    end

    def self.render_file(file, color)
      File.foreach(file, chomp: true).each do |l|
        puts "#{color}#{l}#{C_RESET}"
      end
      nil
    end

    def self.v_logo_lines
      [
        "#{C_RED}__ #{C_GREEN}__ #{C_BLUE}__ __#{C_RESET}",
        "#{C_RED }\\ V#{C_GREEN}\\ V#{C_BLUE}\\ V /#{C_RESET}",
        "#{C_RED} \\_/#{C_GREEN}\\_/#{C_BLUE}\\_/ #{C_RESET}"]
    end
  end
end
