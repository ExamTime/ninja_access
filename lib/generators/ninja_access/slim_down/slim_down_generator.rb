require 'rails/generators/migration'

module NinjaAccess
  module Generators
    class SlimDownGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../../templates', __FILE__)
      puts File.expand_path('../../templates', __FILE__)
      desc "Adding the new ninja_access migrations to the host app"

      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        else
          @prev_migration_nr += 1
        end
        @prev_migration_nr.to_s
      end

      def copy_migrations
        migration_template "drop_ninja_access_sub_groups.rb", "db/migrate/drop_ninja_access_sub_groups.rb"
      end
    end
  end
end
