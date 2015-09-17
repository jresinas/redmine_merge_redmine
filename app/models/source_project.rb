class SourceProject < ActiveRecord::Base
  include SecondDatabase
  set_table_name :projects

  has_many :enabled_modules, :class_name => 'SourceEnabledModule', :foreign_key => 'project_id'
  has_and_belongs_to_many :trackers, :class_name => 'SourceTracker', :join_table => 'projects_trackers', :foreign_key => 'project_id', :association_foreign_key => 'tracker_id'
  has_and_belongs_to_many :issue_custom_fields, :class_name => 'SourceCustomField', :join_table => "custom_fields_projects", :foreign_key => 'project_id', :association_foreign_key => 'custom_field_id'
  has_many :members, :class_name => 'SourceMember'
  
  def self.migrate
    all(:order => 'lft ASC').each do |source_project|
      puts "- Migrating source project ##{source_project.id}: #{source_project.name}..."

      if target_project = RedmineMerge::Merger.get_project_to_merge(source_project)
        puts "-- Found"
      else
        trackers = []
        attributes = RedmineMerge::Utils.hash_attributes_adapter("Project",source_project.attributes)
        target_project = Project.new(attributes) do |p|
          p.status = source_project.status
          if source_project.enabled_modules
            p.enabled_module_names = source_project.enabled_modules.collect(&:name)
          end

          if source_project.trackers
            source_project.trackers.each do |source_tracker|
              merged_tracker = Tracker.find(RedmineMerge::Mapper.get_new_tracker_id(source_tracker.id))
              trackers << merged_tracker if merged_tracker and not trackers.include?(merged_tracker)
            end
          end
        end
        target_project.trackers = trackers
        target_project.save(false)

        puts "-- Not found, created"
      end

      RedmineMerge::Mapper.add_project(source_project.id, target_project.id)
      puts "-- Added to map"

      migrate_custom_fields(source_project, target_project)
    end
  end

  # Migración de los campos personalizados del proyecto
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

  # Migración de las relaciones entre proyectos
  def self.migrate_tree
    Project.record_timestamps = false
    all.each do |source_project|
      puts "- Migrating project tree ##{source_project.id}: #{source_project.name}"
      target_project = Project.find(RedmineMerge::Mapper.get_new_project_id(source_project.id))

      target_project.set_parent!(Project.find(RedmineMerge::Mapper.get_new_project_id(source_project.parent_id))) if source_project.parent_id.present?

      target_project.save(false)
    end
    Project.record_timestamps = true
  end
end
