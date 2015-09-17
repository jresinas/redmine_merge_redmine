class SourceWorkflow < ActiveRecord::Base
  include SecondDatabase
	set_table_name :workflows

	belongs_to :role
	belongs_to :old_status, :class_name => 'IssueStatus', :foreign_key => 'old_status_id'
	belongs_to :new_status, :class_name => 'IssueStatus', :foreign_key => 'new_status_id'

  def self.migrate
    all.each do |source_workflow|
      puts "- Migrating workflow ##{source_workflow.id}"

      attributes = RedmineMerge::Utils.hash_attributes_adapter("Workflow",source_workflow.attributes)
      target_workflow = Workflow.new(attributes) do |wf|
        wf.tracker_id = RedmineMerge::Mapper.get_new_tracker_id(source_workflow.tracker_id)
        wf.old_status_id = RedmineMerge::Mapper.get_new_issue_status_id(source_workflow.old_status_id)
        wf.new_status_id = RedmineMerge::Mapper.get_new_issue_status_id(source_workflow.new_status_id)
        wf.role_id = RedmineMerge::Mapper.get_new_role_id(source_workflow.role_id)

        if wf.tracker_id.present? and wf.old_status_id.present? and wf.new_status_id.present? and wf.role_id.present?
          wf.save
        end
      end
    end
  end
end