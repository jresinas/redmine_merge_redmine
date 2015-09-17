class SourceIssue < ActiveRecord::Base
  include SecondDatabase
  set_table_name :issues

  belongs_to :author, :class_name => 'SourceUser', :foreign_key => 'author_id'
  belongs_to :assigned_to, :class_name => 'SourceUser', :foreign_key => 'assigned_to_id'
  belongs_to :status, :class_name => 'SourceIssueStatus', :foreign_key => 'status_id'
  belongs_to :tracker, :class_name => 'SourceTracker', :foreign_key => 'tracker_id'
  belongs_to :project, :class_name => 'SourceProject', :foreign_key => 'project_id'
  belongs_to :priority, :class_name => 'SourceEnumeration', :foreign_key => 'priority_id'
  belongs_to :category, :class_name => 'SourceIssueCategory', :foreign_key => 'category_id'
  belongs_to :fixed_version, :class_name => 'SourceVersion', :foreign_key => 'fixed_version_id'
  has_many :source_journals, :as => :journalized
  
  def self.migrate
    Issue.record_timestamps = false

    all.each do |source_issue|
      puts "- Migrating issue ##{source_issue.id}: #{source_issue.subject}"
      attributes = RedmineMerge::Utils.hash_attributes_adapter("Issue",source_issue.attributes)

      issue = Issue.new(attributes) do |i|
        i.project = Project.find(RedmineMerge::Mapper.get_new_project_id(source_issue.project_id)) if source_issue.project_id.present?
        puts "-- Set project #{i.project.name}"

        i.author = User.find(RedmineMerge::Mapper.get_new_user_id(source_issue.author.id)) if source_issue.author_id.present?
        puts "-- Set author #{i.author}"

        i.assigned_to = User.find(RedmineMerge::Mapper.get_new_user_id(source_issue.assigned_to.id)) if source_issue.assigned_to_id.present?
        puts "-- Set assignee #{i.assigned_to}"

        i.status = IssueStatus.find(RedmineMerge::Mapper.get_new_issue_status_id(source_issue.status_id)) if source_issue.status_id.present?
        puts "-- Set issue status #{i.status}"

        i.tracker = Tracker.find(RedmineMerge::Mapper.get_new_tracker_id(source_issue.tracker_id)) if source_issue.tracker_id.present?
        puts "-- Set tracker #{i.tracker}"

        i.priority = IssuePriority.find(RedmineMerge::Mapper.get_new_enumeration_id(source_issue.priority.id)) if source_issue.priority_id.present?
        puts "-- Set issue priority #{i.priority}"

        i.category = IssueCategory.find(RedmineMerge::Mapper.get_new_issue_category_id(source_issue.category_id)) if source_issue.category_id.present?
        puts "-- Set category #{i.category}"

        if source_issue.fixed_version and version = Version.find(RedmineMerge::Mapper.get_new_version_id(source_issue.fixed_version.id))
          i.instance_variable_set :@assignable_versions, [version]
          i.fixed_version = version
          puts "-- Set fixed version #{i.fixed_version}"
        end
      end

      # Al inicializar una petición, si tiene una categoria con un usuario asignado, automaticamente la inicializa asignada a ese usuario
      if issue.assigned_to == nil
        issue.save(false)
        issue.update_attribute('assigned_to', nil)
      else
        issue.save(false)
      end

      RedmineMerge::Mapper.add_issue(source_issue.id, issue.id)
    end

    Issue.record_timestamps = true
  end

  # Migración de las relaciones entre tareas
  def self.migrate_tree
    Issue.record_timestamps = false
    all.each do |source_issue|
      puts "- Migrating issue tree ##{source_issue.id}: #{source_issue.subject}"
      target_issue = Issue.find(RedmineMerge::Mapper.get_new_issue_id(source_issue.id))

      target_issue[:parent_id] = RedmineMerge::Mapper.get_new_issue_id(source_issue.parent_id) if source_issue.parent_id.present?
      target_issue[:root_id] = RedmineMerge::Mapper.get_new_issue_id(source_issue.root_id) if source_issue.root_id.present?
      target_issue[:lft] = source_issue.lft
      target_issue[:rgt] = source_issue.rgt

      target_issue.save(false)
    end
    Issue.record_timestamps = true
  end
end
