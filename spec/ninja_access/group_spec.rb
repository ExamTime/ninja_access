require 'spec_helper'

describe NinjaAccess::Group do
  context "creation" do
    it "should require a name" do
      group = build :ninja_access_group, :name => nil
      expect(group).not_to be_valid
    end
  end

  context "instance methods" do
    before :each do
      @group = build(:ninja_access_group)
    end

    [:users, :permissions].each do |association|
      it "should include '#{association}'" do
        expect(@group).to respond_to(association)
      end
    end

    it "should include 'add_user'" do
      expect(@group).to respond_to(:add_user)
    end

    describe "#add_user" do
      before :each do
        @user = User.new
      end

      context "user supplied equals nil" do
        it "should return false" do
          expect(@group.add_user(nil)).to be_falsey
        end

        it "should not affect the users association" do
          orig_count = @group.users.size
          @group.add_user(nil)
          expect(@group.users.size).to eq orig_count
        end
      end

      context "user supplied equals a valid user" do
        it "should add the supplied user to the users association" do
          orig_count = @group.users.size
          @group.add_user(@user)
          expect(@group.users.size).to eq orig_count+1
          expect(@group.users).to include @user
        end

        it "should return true" do
          expect(@group.add_user(@user)).to be_truthy
        end
      end

      context "user supplied is already present in the users association" do
        before :each do
          @group.add_user(@user)
        end

        it "should return false" do
          expect(@group.add_user(@user)).to be_falsey
        end

        it "should not affect the users association" do
          orig_count = @group.users.size
          @group.add_user(nil)
          expect(@group.users.size).to eq orig_count
        end
      end
    end

    it "should include 'add_users'" do
      expect(@group).to respond_to(:add_users)
    end

    describe "#add_users" do
      before :each do
        @user_1 = User.new
        @user_2 = User.new
      end

      context "an empty array is supplied" do
        it "should return true" do
          expect(@group.add_users([])).to be_truthy
        end

        it "should not affect the users association" do
          orig_count = @group.users.size
          @group.add_users([])
          expect(@group.users.size).to eq orig_count
        end
      end

      context "an array of users are supplied" do
        it "should invoke '#add_user' for each of the supplied users" do
          @group.should_receive(:add_user).with(@user_1)
          @group.should_receive(:add_user).with(@user_2)
          @group.add_users([@user_1, @user_2])
        end

        it "should return an array containing all the users added" do
          added = @group.add_users([@user_1, @user_1, @user_2])
          expect(added.size).to eq 2
        end
      end
    end
  end
end
