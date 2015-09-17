class SourceTracker < ActiveRecord::Base
  include SecondDatabase
  set_table_name :trackers

  has_and_belongs_to_many :projects, :class_name => 'SourceProject', :join_table => 'projects_trackers', :foreign_key => 'tracker_id', :association_foreign_key => 'project_id'
  has_and_belongs_to_many :custom_fields, :class_name => 'SourceCustomField', :join_table => "custom_fields_trackers", :foreign_key => 'tracker_id', :association_foreign_key => 'custom_field_id'

  def self.migrate
    all.each do |source_tracker|
      puts "- Migrating tracker ##{source_tracker.id}: #{source_tracker.name}"
      source_tracker.name = RedmineMerge::Merger.check_element_to_rename('tracker', source_tracker.name)
      target_tracker = RedmineMerge::Merger.get_tracker_to_merge(source_tracker)
  			
  	  if !target_tracker.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("Tracker",source_tracker.attributes)
  	    target_tracker = Tracker.create!(attributes)
  	  end

      RedmineMerge::Mapper.add_tracker(source_tracker.id, target_tracker.id)
      migrate_custom_fields(source_tracker, target_tracker)
    end
  end

  # Migración de los campos personalizados del tipo de petición
  def self.migrate_custom_fields(source_tracker, target_tracker)
  	puts "-- migrate custom fields"
    Array(source_tracker.custom_fields).each do |source_custom_field|
      target_custom_field = CustomField.find(RedmineMerge::Mapper.get_new_custom_field_id(source_custom_field.id))
      if target_custom_field.nil?
        puts "    Skipping missing target field #{source_custom_field.name}"
        next
      end
      if target_tracker.custom_fields.include?(target_custom_field)
        puts "    Skipping existing custom field #{source_custom_field.name}"
        next
      end
      puts "    Adding custom field #{source_custom_field.name}"
      target_tracker.custom_fields << target_custom_field
    end
    target_tracker.save
  end
end
