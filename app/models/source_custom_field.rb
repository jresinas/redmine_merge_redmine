class SourceCustomField < ActiveRecord::Base
  include SecondDatabase
  set_table_name :custom_fields

  has_and_belongs_to_many :projects, :class_name => 'SourceProject', :join_table => 'custom_fields_projects', :foreign_key => 'custom_field_id', :association_foreign_key => 'project_id'
  has_and_belongs_to_many :trackers, :class_name => 'SourceTracker', :join_table => 'custom_fields_trackers', :foreign_key => 'custom_field_id', :association_foreign_key => 'tracker_id'


  def self.migrate
    all.each do |source_custom_field|
      puts "- Migrating custom field ##{source_custom_field.id}: #{source_custom_field.name}"
      # Si la clase del tipo de campo personalizado no existe en el código del destino, se salta la migración del campo
      if RedmineMerge::Utils.class_exists?(source_custom_field.type)
        source_custom_field.name = RedmineMerge::Merger.check_element_to_rename('custom_field', source_custom_field.name)
        target_custom_field = RedmineMerge::Merger.get_custom_field_to_merge(source_custom_field)

        if !target_custom_field.present? or target_custom_field.type != source_custom_field.type
          attributes = RedmineMerge::Utils.hash_attributes_adapter("CustomField",source_custom_field.attributes)
        	target_custom_field = CustomField.create!(attributes) do |cf|
            # Type must be set explicitly -- not included in the attributes
            cf.type = source_custom_field.type
    	    end
    	  end
        
        RedmineMerge::Mapper.add_custom_field(source_custom_field.id, target_custom_field.id)
      else
        puts "Custom field type not found"
      end
    end
  end
end
