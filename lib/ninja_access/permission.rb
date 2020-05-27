# NinjaAccess::Permission
#
# This class represents a single granular permission for an individual model instance.
#   * accessible_type defines the class of the model instance to which this permission pertains
#   * accessible_id defines the id of the model instance to which this permission pertains
#   * action defines the user action that this permission represents (e.g. view, edit, delete, extend)
#
# With a permission created the model will only be made accessible when this permission is 'granted'
# to a group. At that point, the permission will be inferred for all members of that group.
#
# At present we do not offer a way for a Permission to grant itself to any group.  Instead, we
# require that the model instance is solely responsible for granting permissions to itself.
#
class NinjaAccess::Permission < ActiveRecord::Base
  validates_presence_of :accessible
  validates_presence_of :action
  validates_uniqueness_of :action, 
    :case_sensitive => true,
    :scope => [:accessible_type, :accessible_id]
  validate :action_is_supported?

  belongs_to :accessible, :polymorphic => true
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

  def self.supported_actions
    NinjaAccess.supported_actions.map{|a| a.to_s}
  end

  private

  def action_is_supported?
    unless NinjaAccess::Permission::supported_actions.include?(action)
      self.errors.add :action, I18n.t("ninja_access.error.message.action_not_supported", :action => action)
    end
  end
end
