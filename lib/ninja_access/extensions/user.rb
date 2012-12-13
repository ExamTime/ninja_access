module NinjaAccess::Extensions::User
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      has_and_belongs_to_many  :ninja_access_permissions,
                               :join_table => "ninja_access_users_permissions",
                               :class_name => "NinjaAccess::Permission"
      has_and_belongs_to_many  :ninja_access_groups,
                               :join_table => "ninja_access_groups_users",
                               :class_name => "NinjaAccess::Group"
    end 
  end

  module ClassMethods
  end
end
