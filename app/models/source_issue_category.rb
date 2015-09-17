class SourceIssueCategory < ActiveRecord::Base
  include SecondDatabase
  set_table_name :issue_categories

  def self.migrate
    all.each do |source_issue_category|
      puts "- Migrating issue category ##{source_issue_category.id}: #{source_issue_category.name}"
      target_issue_category = RedmineMerge::Merger.get_issue_category_to_merge(source_issue_category)

      if !target_issue_category.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("IssueCategory",source_issue_category.attributes)
        target_issue_category = IssueCategory.create!(attributes) do |ic|
          if source_issue_category.project_id.present?
            map_ic = RedmineMerge::Mapper.get_new_project_id(source_issue_category.project_id)

            if map_ic.present?
              ic.project = Project.find(map_ic)
            end
          end

          if source_issue_category.assigned_to_id.present?
            map_ic = RedmineMerge::Mapper.get_new_user_id(source_issue_category.assigned_to_id)

            if map_ic.present?
              ic.assigned_to_id = map_ic
            end
          end
        end
      end

      RedmineMerge::Mapper.add_issue_category(source_issue_category.id, target_issue_category.id)
    end
  end
end
