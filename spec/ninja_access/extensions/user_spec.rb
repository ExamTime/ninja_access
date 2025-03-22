require 'spec_helper'

describe NinjaAccess::Extensions::User do
  let(:user) { User.new }
  context "user instance" do
    it "should have an association for ninja_access_groups" do
      expect(user).to respond_to :ninja_access_groups
    end
  end
end
