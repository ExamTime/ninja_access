FactoryBot.define do
  factory :ninja_access_group, :class => 'NinjaAccess::Group' do
    sequence(:name) {|n| "Group #{n}"}
  end
end
