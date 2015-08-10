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
  
  def self.migrate
    all.each do |source_issue|
      puts "- Migrating issue ##{source_issue.id}: #{source_issue.subject}"
      issue = Issue.new(source_issue.attributes) do |i|
        i.project = Project.find_by_name(source_issue.project.name)
        puts "-- Set project #{i.project.name}"
        i.author = User.find(RedmineMerge::Mapper.get_new_user_id(source_issue.author.id))
        puts "-- Set author #{i.author}"
        i.assigned_to = User.find(RedmineMerge::Mapper.get_new_user_id(source_issue.assigned_to.id)) if source_issue.assigned_to
        puts "-- Set assignee #{i.assigned_to}"
        i.status = IssueStatus.find_by_name(source_issue.status.name)
        puts "-- Set issue status #{i.status}"
        i.tracker = Tracker.find_by_name(source_issue.tracker.name)
        puts "-- Set tracker #{i.tracker}"
        i.priority = IssuePriority.find_by_name(source_issue.priority.name)
        puts "-- Set issue priority #{i.priority}"
        i.category = IssueCategory.find_by_name(source_issue.category.name) if source_issue.category
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
  end

  def self.migrate_tree
    all.each do |source_issue|
      target_issue = Issue.find(RedmineMerge::Mapper.get_new_issue_id(source_issue.id))

      target_issue[:parent_id] = RedmineMerge::Mapper.get_new_issue_id(source_issue.parent_id) if source_issue.parent_id.present?
      target_issue[:lft] = source_issue.lft
      target_issue[:rgt] = source_issue.rgt
      target_issue.update_attribute('root_id', RedmineMerge::Mapper.get_new_issue_id(source_issue.root_id))
    end
  end
end
