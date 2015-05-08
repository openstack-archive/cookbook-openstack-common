actions :create
default_action :create

attribute :service, kind_of: String, name_attribute: true, required: true
attribute :user, kind_of: String, required: true
attribute :pass, kind_of: String, required: true
