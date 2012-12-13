require 'spec_helper'

describe NinjaAccess::SubGroup do
  describe "creation" do
    it "should be valid when all required fields are supplied" do
      build(:ninja_access_sub_group).should be_valid
    end

    it "should be invalid when the parent group is not provided" do
      build(:ninja_access_sub_group, :parent => nil).should_not be_valid
    end

    it "should be invalid when the child group is not provided" do
      build(:ninja_access_sub_group, :child => nil).should_not be_valid
    end

    it "should be invalid then the child group is not unique for the parent group" do
      child_group = build(:ninja_access_group)
      parent_group = build(:ninja_access_group)
      create(:ninja_access_sub_group, :parent => parent_group, :child => child_group)
      build(:ninja_access_sub_group, :parent => parent_group, :child => child_group).should_not be_valid
    end
  end
end
