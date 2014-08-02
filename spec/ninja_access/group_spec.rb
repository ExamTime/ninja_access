require 'spec_helper'

describe NinjaAccess::Group do
  context "creation" do
    it "should require a name" do
      group = build :ninja_access_group, :name => nil
      group.should_not be_valid
    end
  end

  context "instance methods" do
    let(:group) { build(:ninja_access_group) }

    [:users, :permissions].each do |association|
      it "should include '#{association}'" do
        group.should respond_to(association)
      end
    end

    it "should include 'add_user'" do
      group.should respond_to(:add_user)
    end

    describe "#add_user" do
      let(:user) { User.new }

      context "user supplied equals nil" do
        it "should return false" do
          group.add_user(nil).should be_false
        end

        it "should not affect the users association" do
          orig_count = group.users.size
          group.add_user(nil)
          group.users.size.should == orig_count
        end
      end

      context "user supplied equals a valid user" do
        it "should add the supplied user to the users association" do
          orig_count = group.users.size
          group.add_user(user)
          group.users.size.should == orig_count+1
          group.users.should include user
        end

        it "should return true" do
          group.add_user(user).should be_true
        end
      end

      context "user supplied is already present in the users association" do
        before :all do
          group.add_user(user)
        end

        it "should return false" do
          group.add_user(user).should be_false
        end

        it "should not affect the users association" do
          orig_count = group.users.size
          group.add_user(nil)
          group.users.size.should == orig_count
        end
      end

    end

    it "should include 'add_users'" do
      group.should respond_to(:add_users)
    end

    describe "#add_users" do
      let(:user_1) { User.new }
      let(:user_2) { User.new }

      context "an empty array is supplied" do
        it "should return true" do
          group.add_users([]).should be_true
        end

        it "should not affect the users association" do
          orig_count = group.users.size
          group.add_users([])
          group.users.size.should == orig_count
        end
      end

      context "an array of users are supplied" do
        it "should invoke '#add_user' for each of the supplied users" do
          group.should_receive(:add_user).with(user_1)
          group.should_receive(:add_user).with(user_2)
          group.add_users([user_1, user_2])
        end

        it "should return an array containing all the users added" do
          added = group.add_users([user_1, user_1, user_2])
          added.size.should == 2
        end
      end
    end
  end
end
