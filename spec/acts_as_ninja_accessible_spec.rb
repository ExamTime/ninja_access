require 'spec_helper'

describe NinjaAccess::ActsAsNinjaAccessible do

  describe "where class has been marked as 'acts_as_ninja_accessible'" do

    let(:resource) { ResourceA.new(:name => "resource") }

    describe "class methods" do
      NinjaAccess::supported_actions.each do |supported_action|
        scope_name = "#{supported_action}able_by".to_sym
        it "should include class method '#{scope_name}'" do
          ResourceA.should respond_to(scope_name)
        end
      end
    end

    describe "instance methods" do
      let(:user) { u = User.new; u.save!; u }
      let(:user_no_access) { u = User.new; u.save!; u }

      [:permissions].each do |method|
        it "should include method '##{method}'" do
          resource.should respond_to(method)
        end
      end

      NinjaAccess::supported_actions.each do |supported_action|
        # Check for presence of boolean is_actionable_by? methods
        method_name = "is_#{supported_action}able_by?".to_sym
        it "should include method '##{method_name}'" do
          resource.should respond_to(method_name)
        end

        describe "##{method_name}" do
          before :all do
            resource.permissions.delete_all
            resource.grant_permission_to_user(supported_action, user)
          end

          it "should return true if the user has the permission to #{supported_action} the resource" do
            resource.send(method_name, user).should be_true
          end

          it "should return false if the user does not have the permission to #{supported_action} the resource" do
            resource.send(method_name, user_no_access).should be_false
          end

        end

        # Check for presence of methods to create permissions for this instance
        create_method_name = "create_#{supported_action}_permission".to_sym
        it "should include method '##{create_method_name}'" do
          resource.should respond_to(create_method_name)
        end

        describe "##{create_method_name}" do
          before :all do
            @new_permission = resource.send(create_method_name)
          end

          it "should return a permission relating to the present model instance" do
            @new_permission.accessible.should eq resource
          end

          it "should return a permission for action '#{supported_action}'" do
            @new_permission.action.should eq supported_action.to_s
          end

          it "should add the new permissions to the permissions association on the model instance" do
            resource.permissions.should include @new_permission
          end
        end

      end

      it "should include method '#grant_permission_to_group'" do
        resource.should respond_to(:grant_permission_to_group)
      end

      describe "#grant_permission_to_group" do
        let(:group) { build(:ninja_access_group) }

        NinjaAccess.supported_actions.each do |supported_action|
          describe "for an action of '#{supported_action}'" do
            it "should add '#{supported_action}' permission to the appropriate group" do
              group.permissions.for_instance(resource).actionable(supported_action.to_s).size.should eq 0
              resource.grant_permission_to_group(supported_action, group)
              group.permissions.for_instance(resource).actionable(supported_action.to_s).size.should eq 1
            end
            it "should not add '#{supported_action}' permission twice to the appropriate group" do
              group.permissions.for_instance(resource).actionable(supported_action.to_s).size.should eq 0
              resource.grant_permission_to_group(supported_action, group)
              resource.grant_permission_to_group(supported_action, group)
              group.permissions.for_instance(resource).actionable(supported_action.to_s).size.should eq 1
            end
          end
        end
      end

      it "should include method '#grant_permission_to_user'" do
        resource.should respond_to(:grant_permission_to_user)
      end

      describe "#grant_permission_to_user" do
        NinjaAccess.supported_actions.each do |supported_action|
          describe "for an action of '#{supported_action}'" do
            it "should add '#{supported_action}' permission to the appropriate user" do
              user.ninja_access_permissions.for_instance(resource).actionable(supported_action.to_s).size.should eq 0
              resource.grant_permission_to_user(supported_action, user)
              user.ninja_access_permissions.for_instance(resource).actionable(supported_action.to_s).size.should eq 1
            end
            it "should not add '#{supported_action}' permission twice to the appropriate user" do
              user.ninja_access_permissions.for_instance(resource).actionable(supported_action.to_s).size.should eq 0
              resource.grant_permission_to_user(supported_action, user)
              resource.grant_permission_to_user(supported_action, user)
              user.ninja_access_permissions.for_instance(resource).actionable(supported_action.to_s).size.should eq 1
            end
          end
        end
      end

      it "should include method '#grant_permission_to_groups'" do
        resource.should respond_to(:grant_permission_to_groups)
      end

      describe "#grant_permission_to_groups" do
        it "should issue #grant_permission_to_group for each group passed" do
          group_a = double("group_a")
          group_b = double("group_b")
          resource.should_receive(:grant_permission_to_group).with("test", group_a)
          resource.should_receive(:grant_permission_to_group).with("test", group_b)
          resource.grant_permission_to_groups("test", [group_a, group_b])
        end
      end

      it "should include method '#grant_permission_to_users'" do
        resource.should respond_to(:grant_permission_to_users)
      end

      describe "#grant_permission_to_users" do
        it "should issue #grant_permission_to_user for each user passed" do
          user_a = double("user_a")
          user_b = double("user_b")
          resource.should_receive(:grant_permission_to_user).with("test", user_a)
          resource.should_receive(:grant_permission_to_user).with("test", user_b)
          resource.grant_permission_to_users("test", [user_a, user_b])
        end
      end
    end

  end

  describe "where class has not be marked as 'acts_as_ninja_accessible'" do
    let(:no_access_resource) { ResourceC.new(:name => "no access resource") }

    describe "class methods" do
      NinjaAccess::supported_actions.each do |supported_action|
        scope_name = "#{supported_action}able_by".to_sym
        it "should not include class method '#{scope_name}'" do
          ResourceC.should_not respond_to(scope_name)
        end
      end
    end

    describe "instance methods" do
      [:permissions].each do |method|
        it "should not include method '##{method}'" do
          no_access_resource.should_not respond_to(method)
        end
      end

      NinjaAccess::supported_actions.each do |supported_action|
        # Check for absence of boolean is_actionable_by? methods
        method_name = "is_#{supported_action}able_by?".to_sym
        it "should not include method '##{method_name}'" do
          no_access_resource.should_not respond_to(method_name)
        end

        # Check for absence of methods to create permissions for this instance
        method_name = "create_#{supported_action}_permission".to_sym
        it "should not include method '##{method_name}'" do
          no_access_resource.should_not respond_to(method_name)
        end
      end

      it "should not include method '#grant_permission_to_group'" do
        no_access_resource.should_not respond_to(:grant_permission_to_group)
      end

      it "should not include method '#grant_permission_to_user'" do
        no_access_resource.should_not respond_to(:grant_permission_to_user)
      end

    end
  end

end
