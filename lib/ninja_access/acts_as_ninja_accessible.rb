module NinjaAccess::ActsAsNinjaAccessible

  def acts_as_ninja_accessible(options = {})
    include InstanceMethods
    has_many   :permissions,
               :class_name => "NinjaAccess::Permission",
               :as => :accessible,
               :dependent => :destroy

    NinjaAccess::supported_actions.each do |supported_action|
      scope_name = "#{supported_action}able_by".to_sym
      scope scope_name, lambda { |user|
        join_sql = <<-HERE
          INNER JOIN ninja_access_permissions ON (ninja_access_permissions.accessible_id = #{table_name}.id
                                                  AND ninja_access_permissions.accessible_type = '#{self.to_s}')
          LEFT JOIN ninja_access_groups_permissions ON (ninja_access_permissions.id = ninja_access_groups_permissions.permission_id)
          LEFT JOIN ninja_access_groups AS groups ON (ninja_access_groups_permissions.group_id = groups.id)
          LEFT JOIN ninja_access_groups_users AS users ON (groups.id = users.group_id)
        HERE

        where_sql = <<-HERE
          ninja_access_permissions.action = '#{supported_action}'
          AND users.user_id = #{user.id}
          OR #{user.id} IN (#{NinjaAccess.query_for_super_user_ids})
        HERE

        joins(join_sql).where(where_sql).uniq
      }


      scope_name = "#{supported_action}able_by_group".to_sym
      scope scope_name, lambda { |group|
        joins("INNER JOIN ninja_access_permissions ON (ninja_access_permissions.accessible_id = #{table_name}.id
                                                     AND ninja_access_permissions.accessible_type = '#{self.to_s}')
           INNER JOIN ninja_access_groups_permissions ON (ninja_access_permissions.id = ninja_access_groups_permissions.permission_id)
           INNER JOIN ninja_access_groups AS groups ON (ninja_access_groups_permissions.group_id = groups.id)
          ")
        .where("
           ninja_access_permissions.action = '#{supported_action}'
           AND groups.id = #{group.id}")
        .uniq
      }

    end
  end

  module InstanceMethods
    NinjaAccess::supported_actions.each do |supported_action|
      scope_name = "#{supported_action}able_by".to_sym
      instance_method_name = "is_#{scope_name}?".to_sym
      define_method instance_method_name do |user|
        return unless user
        klazz.send(scope_name, user).include?(self)
      end

      scope_name_group = "#{supported_action}able_by_group".to_sym
      instance_method_name_group = "is_#{scope_name_group}?".to_sym
      define_method instance_method_name_group do |group|
        return unless group
        klazz.send(scope_name_group, group).include?(self)
      end
    end

    def grant_permission_to_group(action, group)
      action = action.to_s
      permission = get_my_permission_for_action(action)
      permission.groups << group if not permission.groups.include?(group)
      permission.save!
    end

    def grant_permission_to_groups(action, groups)
      groups.each { |g| grant_permission_to_group(action, g) }
    end

    def revoke_permission_from_group(action, group)
      action = action.to_s
      permission = get_my_permission_for_action(action)
      permission.groups.delete group
      permission.save!
    end

    def revoke_permission_from_groups(action, groups)
      groups.each { |g| revoke_permission_from_group(action, g) }
    end

    NinjaAccess::supported_actions.each do |supported_action|
      create_method_name = "create_#{supported_action}_permission".to_sym
      define_method create_method_name do
        permission = NinjaAccess::Permission.new(:action => supported_action.to_s)
        permission.accessible = self
        permission.save!
        permission
      end
    end

    private

    def get_my_permission_for_action(action)
      permission = self.permissions.where(:action => action).first
      permission ||= self.send("create_#{action}_permission")
      permission
    end

    def klazz
      self.class.name.constantize
    end
  end
end

ActiveRecord::Base.extend NinjaAccess::ActsAsNinjaAccessible
