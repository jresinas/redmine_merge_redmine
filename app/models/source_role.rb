class SourceRole < ActiveRecord::Base
  include SecondDatabase
  set_table_name :roles

  def self.migrate
    all.each do |source_role|
      puts "- Migrating role ##{source_role.id}: #{source_role.name}"

      target_role = RedmineMerge::Merger.get_role_to_merge(source_role)

      if !target_role.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("Role",source_role.attributes)
      	target_role = Role.create!(attributes)
  	  end
      
      RedmineMerge::Mapper.add_role(source_role.id, target_role.id)
    end
  end
end
