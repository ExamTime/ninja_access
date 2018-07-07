require 'spec_helper'

describe NinjaAccess::ActsAsNinjaAccessible do

  describe "where class has been marked as 'acts_as_ninja_accessible'" do

    let(:resource) { ResourceA.new(:name => "resource") }
    let(:user) { u = User.new; u.save!; u }
    let(:superuser) { u = User.new; u.save!; u }
    let(:group) { g = create(:ninja_access_group); g.add_user(user); g }


    describe "class methods" do
      before :each do
        NinjaAccess::query_for_super_user_ids = nil
      end

      NinjaAccess::supported_actions.each do |supported_action|
        ["#{supported_action}able_by".to_sym, "#{supported_action}able_by_group".to_sym].each do |scope_name|
          it "should include class method '#{scope_name}'" do
            ResourceA.should respond_to(scope_name)
          end
        end

        describe "##{supported_action}able_by" do
          it "should return any resources that are #{supported_action}able by the user passed" do
            resource = ResourceA.create(name: 'test with access')
            resource.grant_permission_to_group(supported_action, group)
            expect(ResourceA.send("#{supported_action}able_by", user)).to include resource
          end

          it "should not return any resources that are not #{supported_action}able by the user passed" do
            resource = ResourceA.create(name: 'test with no access')
            expect(ResourceA.send("#{supported_action}able_by", user)).not_to include resource
          end

          it "should return any resources it the user is a superuser" do
            NinjaAccess::query_for_super_user_ids = "SELECT #{superuser.id} FROM DUAL"
            resource = ResourceA.create(name: 'test with no access')
            expect(ResourceA.send("#{supported_action}able_by", superuser)).to include resource
          end
        end

        describe "##{supported_action}able_by_group" do
          it "should return any resources that are #{supported_action}able by the group passed" do
            resource = ResourceA.create(name: 'test with access')
            resource.grant_permission_to_group(supported_action, group)
            expect(ResourceA.send("#{supported_action}able_by_group", group)).to include resource
          end

          it "should not return any resources that are not #{supported_action}able by the user passed" do
            resource = ResourceA.create(name: 'test with access')
            expect(ResourceA.send("#{supported_action}able_by_group", group)).not_to include resource
          end
        end
      end
    end

    describe "instance methods" do
      let(:user_no_access) { u = User.new; u.save!; u }
      let(:group_no_access) { create(:ninja_access_group) }

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
            group.add_user(user)
            resource.grant_permission_to_group(supported_action, group)
          end

          it "should return false if the user is nil" do
            resource.send(method_name, nil).should be_false
          end

          it "should return true if the user has the permission to #{supported_action} the resource" do
            resource.send(method_name, user).should be_true
          end

          it "should return false if the user does not have the permission to #{supported_action} the resource" do
            resource.send(method_name, user_no_access).should be_false
          end

        end

        # Check for presence of boolean is_actionable_by_group? methods
        method_name_group = "is_#{supported_action}able_by_group?".to_sym

        it "should include method '##{method_name_group}'" do
          resource.should respond_to(method_name_group)
        end

        describe "##{method_name_group}" do
          before :all do
            resource.permissions.delete_all
            resource.grant_permission_to_group(supported_action, group)
            resource.reload
          end

          it "should return false if the group is nil" do
            resource.send(method_name_group, nil).should be_false
          end

          it "should return true if the group has the permission to #{supported_action} the resource" do
            resource.send(method_name_group, group).should be_true
          end

          it "should return false if the group does not have the permission to #{supported_action} the resource" do
            resource.send(method_name_group, group_no_access).should be_false
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
            it "should add and remove '#{supported_action}' permission to the appropriate group" do
              group.permissions.for_instance(resource).actionable(supported_action.to_s).size.should eq 0
              resource.grant_permission_to_group(supported_action, group)
              group.permissions.for_instance(resource).actionable(supported_action.to_s).size.should eq 1
              resource.revoke_permission_from_group(supported_action, group)
              group.permissions.for_instance(resource).actionable(supported_action.to_s).size.should eq 0
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

      describe "#revoke_permission_from_groups" do
        it "should include method '#revoke_permission_from_groups'" do
          resource.should respond_to(:revoke_permission_from_groups)
        end

        describe "#revoke_permission_from_groups" do
          it "should issue #revoke_permission_from_group for each user passed" do
            user_a = double("user_a")
            user_b = double("user_b")
            resource.should_receive(:revoke_permission_from_group).with("test", user_a)
            resource.should_receive(:revoke_permission_from_group).with("test", user_b)
            resource.revoke_permission_from_groups("test", [user_a, user_b])
          end
        end
      end
    end
  end

  describe "where class has not be marked as 'acts_as_ninja_accessible'" do
    let(:no_access_resource) { ResourceC.new(:name => "no access resource") }

    describe "class methods" do
      NinjaAccess::supported_actions.each do |supported_action|
        ["#{supported_action}able_by".to_sym, "#{supported_action}able_by".to_sym].each do |scope_name|
          it "should not include class method '#{scope_name}'" do
            ResourceC.should_not respond_to(scope_name)
          end
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
        ["is_#{supported_action}able_by?".to_sym, "is_#{supported_action}able_by_group?".to_sym].each do |method_name|
          it "should not include method '##{method_name}'" do
            no_access_resource.should_not respond_to(method_name)
          end
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

    end
  end

end
