class SourceEnabledModule < ActiveRecord::Base
  include SecondDatabase
  set_table_name :enabled_modules

  def self.migrate
  	all.each do |source_enabled_module|
      puts "- Migrating enabled module ##{source_enabled_module.id}"
      attributes = RedmineMerge::Utils.hash_attributes_adapter("EnabledModule",source_enabled_module.attributes)
      
  		target_enabled_module = EnabledModule.new(attributes) do |em|
        if source_enabled_module.project_id.present?
          em.project_id = RedmineMerge::Mapper.get_new_project_id(source_enabled_module.project_id)
        end
      end
      
  		target_enabled_module.save
  	end
  end
end
