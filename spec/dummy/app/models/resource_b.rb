class ResourceB < ActiveRecord::Base
  attr_accessible :name
  acts_as_ninja_accessible
end
