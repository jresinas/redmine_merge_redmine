class SourceEnabledModule < ActiveRecord::Base
  include SecondDatabase
  set_table_name :enabled_modules

  def self.migrate
  	all.each do |source_enabled_module|
  		project_id = RedmineMerge::Mapper.get_new_project_id(source_enabled_module.project_id)
  		source_enabled_module.project_id = project_id
  		em = EnabledModule.new(source_enabled_module.attributes)
  		em.save
  	end
  end
end
