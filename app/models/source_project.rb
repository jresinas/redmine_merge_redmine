class SourceProject < ActiveRecord::Base
  include SecondDatabase
  set_table_name :projects

  has_many :enabled_modules, :class_name => 'SourceEnabledModule', :foreign_key => 'project_id'
  has_and_belongs_to_many :trackers, :class_name => 'SourceTracker', :join_table => 'projects_trackers', :foreign_key => 'project_id', :association_foreign_key => 'tracker_id'
  has_and_belongs_to_many :issue_custom_fields, :class_name => 'SourceCustomField', :join_table => "custom_fields_projects", :foreign_key => 'project_id', :association_foreign_key => 'custom_field_id'
  has_many :members
  
  def self.migrate
    all(:order => 'lft ASC').each do |source_project|
      puts "- Migrating source project #{source_project.name}..."
      if target_project = (Project.find_by_name(source_project.name) || Project.find_by_identifier(source_project.identifier))
        puts "-- Found"
      else
        target_project = Project.new(source_project.attributes) do |p|
          p.status = source_project.status
          if source_project.enabled_modules
            p.enabled_module_names = source_project.enabled_modules.collect(&:name)
          end

          if source_project.trackers
            source_project.trackers.each do |source_tracker|
              merged_tracker = Tracker.find_by_name(source_tracker.name)
              p.trackers << merged_tracker if merged_tracker and not p.trackers.include?(merged_tracker)
            end
          end
        end
        target_project.save(false)
        # Parent/child projects
        if source_project.parent_id
          target_project.set_parent!(Project.find_by_id(RedmineMerge::Mapper.get_new_project_id(source_project.parent_id)))
        end
        puts "-- Not found, created"
      end
      puts "-- Added to map"
      RedmineMerge::Mapper.add_project(source_project.id, target_project.id)

      migrate_custom_fields(source_project, target_project)
    end
  end

  def self.migrate_custom_fields(source_project, target_project)
    puts "migrate custom fields"
    Array(source_project.issue_custom_fields).each do |source_custom_field|
      target_custom_field = CustomField.find(RedmineMerge::Mapper.get_new_custom_field_id(source_custom_field.id))
      if target_custom_field.nil?
        puts "    Skipping missing target field #{source_custom_field.name}"
        next
      end
      if target_project.issue_custom_fields.include?(target_custom_field)
        puts "    Skipping existing custom field #{source_custom_field.name}"
        next
      end
      puts "    Adding custom field #{source_custom_field.name}"
      target_project.issue_custom_fields << target_custom_field
    end
    target_project.save
  end
end
