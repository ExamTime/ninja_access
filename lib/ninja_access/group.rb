# NinjaAccess::Group
#
# Class representing the concept of a group, which is just a collection of users.
#  * HABTM users: These are the users in the group
#  * HABTM permissions: These are the permissions that have been granted to the group
#
#  Any user of the group assumes all the permissions granted to the group.
#
class NinjaAccess::Group < ActiveRecord::Base
  # Each group is created with a name - uniqueness of this name is not enforced
  attr_accessible :name

  validates_presence_of :name

  has_and_belongs_to_many :users,
                          :join_table => "ninja_access_groups_users"

  has_and_belongs_to_many :permissions,
                          :class_name => "NinjaAccess::Permission",
                          :join_table => "ninja_access_groups_permissions"

  # Add a user to the present group
  #
  # Users of this class can add users to the group using this method.
  #   * user represents an instance of the User class from the host application.
  #   * returns true if the user is successfully added to the group and false otherwise.
  def add_user(user)
    return false unless user
    return false if users.include?(user)
    users << user
    true
  end

  # Add an array of users to the present group
  #
  # Users of this class can add a list of users to the group using this method.
  #   * users represents an array-like argument returning User instances
  #   * returns an array of all users that were successfully added to this group
  def add_users(users)
    return true if users.empty?
    added = []
    users.each do |user|
      added << user if add_user(user)
    end
    added
  end
end
