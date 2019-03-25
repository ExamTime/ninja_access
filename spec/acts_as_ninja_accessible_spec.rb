require 'spec_helper'

describe NinjaAccess::ActsAsNinjaAccessible do

  describe "where class has been marked as 'acts_as_ninja_accessible'" do

    before :all do
      @resource = ResourceA.create!(:name => "resource")

      @user = User.new.tap do |user|
        user.save!
      end

      @superuser = User.new.tap do |user|
        user.save!
      end

      @group = create(:ninja_access_group).tap do |group|
        group.add_user(@user)
      end
    end

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
            resource.grant_permission_to_group(supported_action, @group)
            expect(ResourceA.send("#{supported_action}able_by", @user)).to include resource
          end

          it "should not return any resources that are not #{supported_action}able by the user passed" do
            resource = ResourceA.create(name: 'test with no access')
            expect(ResourceA.send("#{supported_action}able_by", @user)).not_to include resource
          end

          it "should return any resources it the user is a superuser" do
            NinjaAccess::query_for_super_user_ids = "SELECT #{@superuser.id} FROM DUAL"
            resource = ResourceA.create(name: 'test with no access')
            expect(ResourceA.send("#{supported_action}able_by", @superuser)).to include resource
          end
        end

        describe "##{supported_action}able_by_@group" do
          it "should return any resources that are #{supported_action}able by the @group passed" do
            resource = ResourceA.create(name: 'test with access')
            resource.grant_permission_to_group(supported_action, @group)
            expect(ResourceA.send("#{supported_action}able_by_group", @group)).to include resource
          end

          it "should not return any resources that are not #{supported_action}able by the user passed" do
            resource = ResourceA.create(name: 'test with access')
            expect(ResourceA.send("#{supported_action}able_by_group", @group)).not_to include resource
          end
        end
      end
    end

    describe "instance methods" do

      before :each do
        @user_no_access = User.new.tap do |user|
          user.save!
        end
        @group_no_access = create(:ninja_access_group)
      end

      [:permissions].each do |method|
        it "should include method '##{method}'" do
          expect(@resource).to respond_to(method)
        end
      end

      NinjaAccess::supported_actions.each do |supported_action|
        # Check for presence of boolean is_actionable_by? methods
        method_name = "is_#{supported_action}able_by?".to_sym

        it "should include method '##{method_name}'" do
          expect(@resource).to respond_to(method_name)
        end

        describe "##{method_name}" do
          before :all do
            @resource_a = ResourceA.new(:name => "nuffer resource")
            @group.add_user(@user)
            @resource_a.grant_permission_to_group(supported_action, @group)
          end

          it "should return false if the user is nil" do
            expect(@resource_a.send(method_name, nil)).to be_falsey
          end

          it "should return true if the user has the permission to #{supported_action} the resource" do
            expect(@resource_a.send(method_name, @user)).to be_truthy
          end

          it "should return false if the user does not have the permission to #{supported_action} the resource" do
            expect(@resource_a.send(method_name, @user_no_access)).to be_falsey
          end
        end

        # Check for presence of boolean is_actionable_by_@group? methods
        method_name_group = "is_#{supported_action}able_by_group?".to_sym

        it "should include method '##{method_name_group}'" do
          expect(@resource).to respond_to(method_name_group)
        end

        describe "##{method_name_group}" do
          before :all do
            @resource_b = ResourceA.new(:name => "anna nuffer resource")
            @resource_b.grant_permission_to_group(supported_action, @group)
            @resource_b.reload
          end

          it "should return false if the @group is nil" do
            expect(@resource_b.send(method_name_group, nil)).to be_falsey
          end

          it "should return true if the @group has the permission to #{supported_action} the resource" do
            expect(@resource_b.send(method_name_group, @group)).to be_truthy
          end

          it "should return false if the @group does not have the permission to #{supported_action} the resource" do
            expect(@resource_b.send(method_name_group, @group_no_access)).to be_falsey
          end
        end


        # Check for presence of methods to create permissions for this instance
        create_method_name = "create_#{supported_action}_permission".to_sym
        it "should include method '##{create_method_name}'" do
          expect(@resource).to respond_to(create_method_name)
        end

        describe "##{create_method_name}" do
          before :each do
            @new_permission = @resource.send(create_method_name)
          end

          it "should return a permission relating to the present model instance" do
            expect(@new_permission.accessible).to eq @resource
          end

          it "should return a permission for action '#{supported_action}'" do
            expect(@new_permission.action).to eq supported_action.to_s
          end

          it "should add the new permissions to the permissions association on the model instance" do
            expect(@resource.permissions.reload).to include @new_permission
          end
        end
      end

      it "should include method '#grant_permission_to_@group'" do
        expect(@resource).to respond_to(:grant_permission_to_group)
      end

      describe "#grant_permission_to_@group" do
        before :each do
          @group = create(:ninja_access_group)
        end

        NinjaAccess.supported_actions.each do |supported_action|
          describe "for an action of '#{supported_action}'" do
            it "should add and remove '#{supported_action}' permission to the appropriate @group" do
              expect(@group.permissions.for_instance(@resource).actionable(supported_action.to_s).size).to eq 0
              @resource.grant_permission_to_group(supported_action, @group)
              expect(@group.permissions.for_instance(@resource).actionable(supported_action.to_s).size).to eq 1
              @resource.revoke_permission_from_group(supported_action, @group)
              expect(@group.permissions.for_instance(@resource).actionable(supported_action.to_s).size).to eq 0
            end

            it "should not add '#{supported_action}' permission twice to the appropriate @group" do
              expect(@group.permissions.for_instance(@resource).actionable(supported_action.to_s).size).to eq 0
              @resource.grant_permission_to_group(supported_action, @group)
              @resource.grant_permission_to_group(supported_action, @group)
              expect(@group.permissions.for_instance(@resource).actionable(supported_action.to_s).size).to eq 1
            end
          end
        end
      end

      it "should include method '#grant_permission_to_groups'" do
        expect(@resource).to respond_to(:grant_permission_to_groups)
      end

      describe "#grant_permission_to_@groups" do
        it "should issue #grant_permission_to_@group for each group passed" do
          group_a = double("group_a")
          group_b = double("group_b")
          @resource.should_receive(:grant_permission_to_group).with("test", group_a)
          @resource.should_receive(:grant_permission_to_group).with("test", group_b)
          @resource.grant_permission_to_groups("test", [group_a, group_b])
        end
      end

      describe "#revoke_permission_from_@groups" do
        it "should include method '#revoke_permission_from_@groups'" do
          expect(@resource).to respond_to(:revoke_permission_from_groups)
        end

        describe "#revoke_permission_from_@groups" do
          it "should issue #revoke_permission_from_@group for each user passed" do
            user_a = double("user_a")
            user_b = double("user_b")
            @resource.should_receive(:revoke_permission_from_group).with("test", user_a)
            @resource.should_receive(:revoke_permission_from_group).with("test", user_b)
            @resource.revoke_permission_from_groups("test", [user_a, user_b])
          end
        end
      end
    end
  end

  describe "where class has not be marked as 'acts_as_ninja_accessible'" do
    before :each do
      @no_access_resource = ResourceC.new(:name => "no access resource")
    end

    describe "class methods" do
      NinjaAccess::supported_actions.each do |supported_action|
        ["#{supported_action}able_by".to_sym, "#{supported_action}able_by".to_sym].each do |scope_name|
          it "should not include class method '#{scope_name}'" do
            expect(ResourceC).not_to respond_to(scope_name)
          end
        end
      end
    end

    describe "instance methods" do
      [:permissions].each do |method|
        it "should not include method '##{method}'" do
          expect(@no_access_resource).not_to respond_to(method)
        end
      end

      NinjaAccess::supported_actions.each do |supported_action|
        # Check for absence of boolean is_actionable_by? methods
        ["is_#{supported_action}able_by?".to_sym, "is_#{supported_action}able_by_@group?".to_sym].each do |method_name|
          it "should not include method '##{method_name}'" do
            expect(@no_access_resource).not_to respond_to(method_name)
          end
        end

        # Check for absence of methods to create permissions for this instance
        method_name = "create_#{supported_action}_permission".to_sym
        it "should not include method '##{method_name}'" do
          expect(@no_access_resource).not_to respond_to(method_name)
        end
      end

      it "should not include method '#grant_permission_to_@group'" do
        expect(@no_access_resource).not_to respond_to(:grant_permission_to_group)
      end
    end
  end
end
