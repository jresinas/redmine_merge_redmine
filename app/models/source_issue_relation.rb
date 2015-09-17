class SourceIssueRelation < ActiveRecord::Base
  include SecondDatabase
  set_table_name :issue_relations

  belongs_to :issue_from, :class_name => 'SourceIssue', :foreign_key => 'issue_from_id'
  belongs_to :issue_to, :class_name => 'SourceIssue', :foreign_key => 'issue_to_id'
  
  def self.migrate
    all.each do |source_issue_relation|
      puts "- Migrating issue relation ##{source_issue_relation.id}"
      attributes = RedmineMerge::Utils.hash_attributes_adapter("IssueRelation",source_issue_relation.attributes)
      
      IssueRelation.create!(attributes) do |ir|
        ir.issue_from = Issue.find(RedmineMerge::Mapper.get_new_issue_id(source_issue_relation.issue_from_id)) if source_issue_relation.issue_from_id.present?
        ir.issue_to = Issue.find(RedmineMerge::Mapper.get_new_issue_id(source_issue_relation.issue_to_id)) if source_issue_relation.issue_to_id.present?
      end
    end
  end
end
