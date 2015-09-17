class SourceEnumeration < ActiveRecord::Base
  include SecondDatabase
  set_table_name :enumerations

  def self.migrate_issue_priorities
    all(:conditions => {:type => "IssuePriority"}).each do |source_issue_priority|
      puts "- Migrating issue priority ##{source_issue_priority.id}: #{source_issue_priority.name}"
      source_issue_priority.name = RedmineMerge::Merger.check_element_to_rename('issue_priority', source_issue_priority.name)
      target_issue_priority = RedmineMerge::Merger.get_enumeration_to_merge(source_issue_priority)

      if !target_issue_priority.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("IssuePriority",source_issue_priority.attributes)

        target_issue_priority = IssuePriority.new(attributes) do |ip|
          if source_issue_priority.project_id.present?
            ip.project_id = RedmineMerge::Mapper.get_new_project_id(source_issue_priority.project_id)
          end
        end

        target_issue_priority.save(false)
      end

      RedmineMerge::Mapper.add_enumeration(source_issue_priority.id, target_issue_priority.id)
    end
  end

  def self.migrate_time_entry_activities
    all(:conditions => {:type => "TimeEntryActivity"}).each do |source_time_entry_activity|
      puts "- Migrating time entry activity ##{source_time_entry_activity.id}: #{source_time_entry_activity.name}"
      source_time_entry_activity.name = RedmineMerge::Merger.check_element_to_rename('time_entry_activity', source_time_entry_activity.name)
      target_time_entry_activity = RedmineMerge::Merger.get_enumeration_to_merge(source_time_entry_activity)
      
      if !target_time_entry_activity.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("TimeEntryActivity",source_time_entry_activity.attributes)

        target_time_entry_activity = TimeEntryActivity.new(attributes) do |tea|
          if source_time_entry_activity.project_id.present?
            tea.project_id = RedmineMerge::Mapper.get_new_project_id(source_time_entry_activity.project_id)
          end
        end

        target_time_entry_activity.save(false)
      end

      RedmineMerge::Mapper.add_enumeration(source_time_entry_activity.id, target_time_entry_activity.id)
    end
  end

  def self.migrate_document_categories
    all(:conditions => {:type => "DocumentCategory"}).each do |source_document_category|
      puts "- Migrating document category ##{source_document_category.id}: #{source_document_category.name}"
      source_document_category.name = RedmineMerge::Merger.check_element_to_rename('document_category', source_document_category.name)
      target_document_category = RedmineMerge::Merger.get_enumeration_to_merge(source_document_category)

      if !target_document_category.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("DocumentCategory",source_document_category.attributes)

        target_document_category = DocumentCategory.new(attributes) do |dc|
          if source_document_category.project_id.present?
            dc.project_id = RedmineMerge::Mapper.get_new_project_id(source_document_category.project_id)
          end
        end

        target_document_category.save(false)
      end

      RedmineMerge::Mapper.add_enumeration(source_document_category.id, target_document_category.id)
    end
  end

end
