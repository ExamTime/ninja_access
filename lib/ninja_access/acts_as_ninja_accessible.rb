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
        joins("INNER JOIN ninja_access_permissions ON (ninja_access_permissions.accessible_id = #{table_name}.id
                                                     AND ninja_access_permissions.accessible_type = '#{self.to_s}')

           LEFT JOIN ninja_access_users_permissions ON (ninja_access_permissions.id = ninja_access_users_permissions.permission_id)

           LEFT JOIN ninja_access_groups_permissions ON (ninja_access_permissions.id = ninja_access_groups_permissions.permission_id)
           LEFT JOIN ninja_access_groups AS direct_groups ON (ninja_access_groups_permissions.group_id = direct_groups.id)
           LEFT JOIN ninja_access_groups_users AS direct_users ON (direct_groups.id = direct_users.group_id)

           LEFT JOIN ninja_access_sub_groups ON (direct_groups.id = ninja_access_sub_groups.parent_id)
           LEFT JOIN ninja_access_groups AS child_groups ON (ninja_access_sub_groups.child_id = child_groups.id)
           LEFT JOIN ninja_access_groups_users AS child_users ON (child_groups.id = child_users.group_id)
          ")
        .where("
           ninja_access_permissions.action = '#{supported_action}'
           AND (
            ninja_access_users_permissions.user_id = #{user.id}
            OR direct_users.user_id = #{user.id}
            OR child_users.user_id = #{user.id}
           )
           OR #{user.id} IN (#{NinjaAccess.query_for_super_user_ids})")
        .uniq
      }


      scope_name = "#{supported_action}able_by_group".to_sym
      scope scope_name, lambda { |group|
        joins("INNER JOIN ninja_access_permissions ON (ninja_access_permissions.accessible_id = #{table_name}.id
                                                     AND ninja_access_permissions.accessible_type = '#{self.to_s}')
           INNER JOIN ninja_access_groups_permissions ON (ninja_access_permissions.id = ninja_access_groups_permissions.permission_id)
           INNER JOIN ninja_access_groups AS direct_groups ON (ninja_access_groups_permissions.group_id = direct_groups.id)
          ")
        .where("
           ninja_access_permissions.action = '#{supported_action}'
           AND direct_groups.id = #{group.id}")
        .uniq
      }

    end
  end

  module InstanceMethods
    NinjaAccess::supported_actions.each do |supported_action|
      scope_name = "#{supported_action}able_by".to_sym
      instance_method_name = "is_#{scope_name}?".to_sym
      define_method instance_method_name do |user|
        klazz.send(scope_name, user).include?(self)
      end

      scope_name_group = "#{supported_action}able_by_group".to_sym
      instance_method_name_group = "is_#{scope_name_group}?".to_sym
      define_method instance_method_name_group do |group|
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

    def grant_permission_to_user(action, user)
      action = action.to_s
      permission = get_my_permission_for_action(action)
      permission.users << user if not permission.users.include?(user)
      permission.save!
    end

    def grant_permission_to_users(action, users)
      users.each { |u| grant_permission_to_user(action, u) }
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

    def revoke_permission_from_user(action, user)
      action = action.to_s
      permission = get_my_permission_for_action(action)
      permission.users.delete user
      permission.save!
    end

    def revoke_permission_from_users(action, users)
      users.each { |u| revoke_permission_from_user(action, u) }
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
