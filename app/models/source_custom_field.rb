class SourceCustomField < ActiveRecord::Base
  include SecondDatabase
  set_table_name :custom_fields

  has_and_belongs_to_many :projects, :class_name => 'SourceProject', :join_table => 'custom_fields_projects', :foreign_key => 'custom_field_id', :association_foreign_key => 'project_id'
  has_and_belongs_to_many :trackers, :class_name => 'SourceTracker', :join_table => 'custom_fields_trackers', :foreign_key => 'custom_field_id', :association_foreign_key => 'tracker_id'


  def self.migrate
    all.each do |source_custom_field|
      target_custom_field = CustomField.find_by_name(source_custom_field.name)

      if !target_custom_field.present? or target_custom_field.type != source_custom_field.type
      	target_custom_field = CustomField.create!(source_custom_field.attributes) do |cf|
          # Type must be set explicitly -- not included in the attributes
          cf.type = source_custom_field.type
  	    end
  	  end
      
      RedmineMerge::Mapper.add_custom_field(source_custom_field.id, target_custom_field.id)
    end
  end
end
