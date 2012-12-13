# NinjaAccess::Permission
#
# This class represents a single granular permission for an individual model instance.
#   * accessible_type defines the class of the model instance to which this permission pertains
#   * accessible_id defines the id of the model instance to which this permission pertains
#   * action defines the user action that this permission represents (e.g. view, edit, delete, extend)
#
# With a permission created the model will only be made accessible when this permission is 'granted'
# to either a group or a user.
#
# At present we do not offer a way for a Permission to grant itself to any user or group.  Instead, we
# require that the model instance is solely responsible to for granting permissions to itself.
#
class NinjaAccess::Permission < ActiveRecord::Base
  attr_accessible :action

  validates_presence_of :accessible
  validates_presence_of :action
  validates_inclusion_of :action, :in => NinjaAccess.supported_actions.map{|a| a.to_s}
  validates_uniqueness_of :action, :scope => [:accessible_type, :accessible_id]

  belongs_to :accessible, :polymorphic => true
  has_and_belongs_to_many :users,
                          :join_table => "ninja_access_users_permissions"
  has_and_belongs_to_many :groups,
                          :class_name => "NinjaAccess::Group",
                          :join_table => "ninja_access_groups_permissions"

  scope :actionable, lambda { |action| where(:action => action) }
  scope :for_type, lambda { |type| where(:accessible_type => type) }
  scope :for_instance, lambda { |instance| where(:accessible_type => instance.class.name, :accessible_id => instance.id) }

  NinjaAccess::supported_actions.each do |supported_action|
    scope_name = "#{supported_action}able".to_sym
    scope scope_name, lambda { actionable(supported_action) }
  end
end
