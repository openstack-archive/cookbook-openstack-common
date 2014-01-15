# encoding: UTF-8

# for yum cookbook LWRPs
# yum_key
def add_yum_key(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:yum_key, :add, resource_name)
end

def remove_yum_key(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:yum_key, :remove, resource_name)
end

# yum_repository
def add_yum_repository(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:yum_repository, :add, resource_name)
end

def remove_yum_repository(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:yum_repository, :remove, resource_name)
end

def update_yum_repository(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:yum_repository, :update, resource_name)
end

def create_yum_repository(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:yum_repository, :create, resource_name)
end
