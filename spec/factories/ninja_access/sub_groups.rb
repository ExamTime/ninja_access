FactoryGirl.define do
  factory :ninja_access_sub_group, :class => 'NinjaAccess::SubGroup' do
    ignore do
      parent { build_stubbed(:ninja_access_group) }
      child { build_stubbed(:ninja_access_group) }
    end

    after :build do |sub_group, proxy|
      sub_group.parent ||= proxy.parent
      sub_group.child ||= proxy.child
    end
  end
end
