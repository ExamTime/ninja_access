Rails.application.reloader.to_prepare do
  NinjaAccess.setup do |config|
    config.query_for_super_user_ids = "SELECT '' FROM DUAL WHERE false"
    config.supported_actions = [:view, :edit, :delete, :extend]
  end
  User.send :include, NinjaAccess::Extensions::User
end
