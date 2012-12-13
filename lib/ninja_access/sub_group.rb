# NinjaAccess::SubGroup
#
# This class represents an implementation detail of the NinjaAccess plugin.
# The purpose of this class is to allow for a group to be composed of other groups.
#
# In general, a given NinjaAccess::Group can belong to many other NinjaAccess::Group instances AND
# can, itself, have many other NinjaAccess::Group instances as sub groups.
# However, this association is more sophisticated than a regular HABTM relationship. This is because we
# need to know the direction of the association (i.e. the concepts of parent and child are significant).
#
# Child groups benefit from the inheritance of permissions that have been granted to the parent, but we do
# not want the parent to inherit any permissions from the children.  
# The presence of this class to mediate the association between NinjaAccess::Groups allows us to maintain 
# this directional significance.
#
class NinjaAccess::SubGroup < ActiveRecord::Base
  belongs_to :parent, :class_name => "NinjaAccess::Group", :inverse_of => :sub_groups
  belongs_to :child, :class_name => "NinjaAccess::Group"

  validates_presence_of :parent
  validates_presence_of :child
  validates_uniqueness_of :child_id, :scope => [:parent_id]
end
