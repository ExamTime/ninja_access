FactoryBot.define do
  factory :ninja_access_permission, :class => 'NinjaAccess::Permission' do
    transient do
      accessible { ResourceA.new(:name => "ResourceA #{Time.now}") }
    end

    action { NinjaAccess.supported_actions.sample.to_s }

    after :build do |permission, proxy|
      permission.accessible ||= proxy.accessible
    end
  end
end
