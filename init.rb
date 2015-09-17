Dir["#{File.dirname(__FILE__)}/config/initializers/**/*.rb"].sort.each do |initializer|
  Kernel.load(initializer)
end

require 'redmine'

require 'second_database'

Redmine::Plugin.register :redmine_merge_redmine do
  author 'Eric Davis, Emergya'
  description 'A plugin to merge two Redmine databases'
  version '1.0.0'

  requires_redmine :version_or_higher => '0.8.0'
end
