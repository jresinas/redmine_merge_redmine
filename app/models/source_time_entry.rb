class SourceTimeEntry < ActiveRecord::Base
  include SecondDatabase
  set_table_name :time_entries

  belongs_to :user, :class_name => 'SourceUser', :foreign_key => 'user_id'
  belongs_to :project, :class_name => 'SourceProject', :foreign_key => 'project_id'
  belongs_to :issue, :class_name => 'SourceIssue', :foreign_key => 'issue_id'
  belongs_to :activity, :class_name => 'SourceEnumeration', :foreign_key => 'activity_id'
  

  def self.migrate
    all.each do |source_time_entry|
      puts "- Migrating time entry ##{source_time_entry.id} for issue ##{source_time_entry.issue_id} "

      attributes = RedmineMerge::Utils.hash_attributes_adapter("TimeEntry",source_time_entry.attributes)
      time_entry = TimeEntry.new(attributes) do |te|
        te.user = User.find(RedmineMerge::Mapper.get_new_user_id(source_time_entry.user.id))
        te.project = Project.find(RedmineMerge::Mapper.get_new_project_id(source_time_entry.project_id))
        te.activity = TimeEntryActivity.find(RedmineMerge::Mapper.get_new_enumeration_id(source_time_entry.activity.id))

        # optional 
        te.issue = Issue.find(RedmineMerge::Mapper.get_new_issue_id(source_time_entry.issue.id)) if source_time_entry.issue_id
      end
      
      time_entry.save(false)
    end
  end
end
