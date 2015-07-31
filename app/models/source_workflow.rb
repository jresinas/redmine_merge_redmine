class SourceWorkflow < ActiveRecord::Base
  include SecondDatabase
	set_table_name :workflows

	belongs_to :role
	belongs_to :old_status, :class_name => 'IssueStatus', :foreign_key => 'old_status_id'
	belongs_to :new_status, :class_name => 'IssueStatus', :foreign_key => 'new_status_id'

  def self.migrate
    all.each do |source_workflow|

      target_workflow = Workflow.new(source_workflow.attributes) do |wf|
        wf.author = RedmineMerge::Mapper.get_new_user_id(source_workflow.author) if source_workflow.author.present?
        wf.assignee = RedmineMerge::Mapper.get_new_user_id(source_workflow.assignee) if source_workflow.assignee.present?
        wf.tracker_id = RedmineMerge::Mapper.get_new_tracker_id(source_workflow.tracker_id)
        wf.old_status_id = RedmineMerge::Mapper.get_new_issue_status_id(source_workflow.old_status_id)
        wf.new_status_id = RedmineMerge::Mapper.get_new_issue_status_id(source_workflow.new_status_id)
        wf.role_id = RedmineMerge::Mapper.get_new_role_id(source_workflow.role_id)

        wf.save
      end
    end
  end
end