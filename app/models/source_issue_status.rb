class SourceIssueStatus < ActiveRecord::Base
  include SecondDatabase
  set_table_name :issue_statuses

  def self.migrate
    all.each do |source_issue_status|      
      puts "- Migrating issue status ##{source_issue_status.id}"
      source_issue_status.name = RedmineMerge::Merger.check_element_to_rename('issue_status', source_issue_status.name)
      target_issue_status = RedmineMerge::Merger.get_issue_status_to_merge(source_issue_status)

      if !target_issue_status.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("IssueStatus",source_issue_status.attributes)
      	target_issue_status = IssueStatus.create!(attributes)
      end
      
      RedmineMerge::Mapper.add_issue_status(source_issue_status.id, target_issue_status.id)
    end
  end
end