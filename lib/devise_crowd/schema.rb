Devise::Schema.class_eval do
  def crowd_authenticatable(options={})
    null    = options[:null] || false
    default = options.key?(:default) ? options[:default] : ("" if null == false)

    apply_devise_schema :crowd_username, String, :null => null, :default => default
  end
end
