class SourceRole < ActiveRecord::Base
  include SecondDatabase
  set_table_name :roles

  def self.migrate
    all.each do |source_role|
      target_role = Role.find_by_name(source_role.name)

      if !target_role.present?
      	target_role = Role.create!(source_role.attributes)
  	  end
      
      RedmineMerge::Mapper.add_role(source_role.id, target_role.id)
    end
  end
end
