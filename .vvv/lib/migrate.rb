module VVV
  class Migrate
    DATABASE_BACKUP_DIRECTORY = File.join(
      VVV::Info.vagrant_dir, 'database/sql/backups/'
    ).freeze

    OLD_DATABASE_BACKUP_DIRECTORY = File.join(
      VVV::Info.vagrant_dir, 'database/backups/'
    ).freeze

    def self.migrate_sql_database_backups
      if sql_database_backups_to_migrate?
        if move_sql_database_backups
          VVV::SplashScreens.info_sql_database_migration(
            OLD_DATABASE_BACKUP_DIRECTORY, DATABASE_BACKUP_DIRECTORY
          )
          return true
        end
      end
      false
    end

    def self.migrate_config
      unless config_exists?
        if old_config_exists?
          if migrate_from_old
            VVV::SplashScreens.info_config_migration(
              VVV::Config::OLD_CONFIG_FILE,
              VVV::Config::CONFIG_FILE
            )
            return true
          end
        elsif default_exists?
          if migrate_from_default
            VVV::SplashScreens.info_config_migration(
              VVV::Config::DEFAULT_CONFIG_FILE,
              VVV::Config::CONFIG_FILE
            )
            return true
          end
        end
      end
      false
    end

    private

    def self.sql_database_backups_to_migrate?
      (
        File.directory?(OLD_DATABASE_BACKUP_DIRECTORY) &&
        File.directory?(DATABASE_BACKUP_DIRECTORY)
      )
    end

    def self.move_sql_database_backups
      FileUtils.mv(OLD_DATABASE_BACKUP_DIRECTORY, DATABASE_BACKUP_DIRECTORY)
    end

    def self.migrate_from_default
      return FileUtils.cp(
        VVV::Config::DEFAULT_CONFIG_FILE,
        VVV::Config::CONFIG_FILE
      )
    end
    def self.migrate_from_old
      FileUtils.mv(
        VVV::Config::OLD_CONFIG_FILE,
        VVV::Config::CONFIG_FILE
      )
    end
    def self.config_exists?
      File.file?(VVV::Config::OLD_CONFIG_FILE)
    end
    def self.old_config_exists?
      File.file?(VVV::Config::OLD_CONFIG_FILE)
    end
    def self.default_exists?
      File.file?(VVV::Config::DEFAULT_CONFIG_FILE)
    end
  end
end
