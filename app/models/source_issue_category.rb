class SourceIssueCategory < ActiveRecord::Base
  include SecondDatabase
  set_table_name :issue_categories

  def self.migrate
    all.each do |source_issue_category|
      next if IssueCategory.find_by_name_and_project_id(source_issue_category.name, source_issue_category.project_id)

      IssueCategory.create!(source_issue_category.attributes) do |ic|
        map_ic = RedmineMerge::Mapper.get_new_project_id(source_issue_category.project_id)
        if map_ic.present?
          ic.project = Project.find(map_ic)
        end

        map_ic = RedmineMerge::Mapper.get_new_user_id(source_issue_category.assigned_to_id)
        if map_ic.present?
          ic.assigned_to_id = User.find(map_ic)
        end
      end
    end
  end
end
