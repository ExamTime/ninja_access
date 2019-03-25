require 'spec_helper'

describe NinjaAccess::Permission do
  let(:resource_a) { ResourceA.new(:name => "A resource") }
  let(:resource_b) { ResourceB.new(:name => "B resource") }

  describe "creation" do
    it "should be valid when all required fields are supplied" do
      expect(build(:ninja_access_permission)).to be_valid
    end

    it "should not be valid when the action is nil" do
      expect(build(:ninja_access_permission, :action => nil)).not_to be_valid
    end

    it "should not be valid when accessible is nil" do
      expect(build(:ninja_access_permission, :accessible => nil)).not_to be_valid
    end

    NinjaAccess.supported_actions.each do |supported_action|
      it "should be valid when the action is '#{supported_action}'" do
        expect(build(:ninja_access_permission, :action => supported_action.to_s)).to be_valid
      end
    end

    [:vue, "nuke", "inflate", "$%^", ""].each do |unsupported_action|
      context "when action is '#{unsupported_action}'" do
        it "should be invalid" do
          expect(build(:ninja_access_permission, :action => unsupported_action)).not_to be_valid
        end

        error_msg = I18n.t("ninja_access.error.message.action_not_supported", :action => unsupported_action)
        it "should have an error message of '#{error_msg}'" do
          p = build(:ninja_access_permission, :action => unsupported_action)
          expect(p).not_to be_valid
          expect(p.errors[:action]).to include error_msg
        end
      end
    end
  end

  context "scopes" do
    before :each do 
      resource_a.permissions.delete_all
    end

    NinjaAccess::supported_actions.each do |supported_action|
      scope_name = "#{supported_action}able".to_sym
      it "should include '#{scope_name}'" do
        expect(NinjaAccess::Permission).to respond_to(scope_name)
      end

      describe "#{scope_name}" do
        it "should filter permissions on the '#{supported_action}' action" do
          expect(NinjaAccess::Permission.send(scope_name).where_values_hash).to include({"action" => supported_action})
        end

        it "should only return '#{scope_name}' permissions with the #{scope_name} scope" do
          # Create a permission on resource_a for the permission currently under test
          resource_a.send("create_#{supported_action}_permission")
          resource_a.save!
          # Consider another action, besides the one currently under test
          other_action = NinjaAccess.supported_actions.reject{ |a| a==supported_action }.sample
          resource_a.send("create_#{other_action}_permission")
          resource_a.save!

          this_permission = resource_a.permissions.where(:action => supported_action).first
          other_permission = resource_a.permissions.where(:action => other_action).first

          expect(NinjaAccess::Permission.send(scope_name)).to include this_permission
          expect(NinjaAccess::Permission.send(scope_name)).not_to include other_permission
        end
      end
    end

    it "should include 'for_type'" do
      expect(NinjaAccess::Permission).to respond_to(:for_type)
    end

    it "should filter permissions on the accessible_type" do
      expect(NinjaAccess::Permission.for_type("ResourceA").where_values_hash).to include({"accessible_type" => "ResourceA"})
    end

    it "should only return permissions of specified type with the for_type scope" do
      NinjaAccess::Permission.for_type("ResourceA").each { |permission|
        expect(permission.accessible_type).to eq "ResourceA"
      }
      NinjaAccess::Permission.for_type("ResourceB").each { |permission|
        expect(permission.accessible_type).to eq "ResourceB"
      }
    end
  end
end
