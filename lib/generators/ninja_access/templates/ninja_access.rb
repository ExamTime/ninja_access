NinjaAccess.setup do |config|
  config.query_for_super_user_ids = nil
  config.supported_actions = [:view, :edit, :delete, :extend]
end

ActionDispatch::Callbacks.to_prepare do
  User.send :include, NinjaAccess::Extensions::User
end
