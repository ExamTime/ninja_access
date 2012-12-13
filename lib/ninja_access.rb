module NinjaAccess

  mattr_accessor :query_for_super_user_ids
  @@query_for_super_user_ids = nil

  mattr_accessor :supported_actions
  @@supported_actions = [:view, :edit, :delete, :extend]

  def self.setup
    yield self
  end

  def self.table_name_prefix
    'ninja_access_'
  end
end

require 'ninja_access/acts_as_ninja_accessible'
require 'ninja_access/permission'
require 'ninja_access/group'
require 'ninja_access/sub_group'
require 'ninja_access/extensions'
