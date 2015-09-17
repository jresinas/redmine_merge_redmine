class SourceCustomValue < ActiveRecord::Base
  include SecondDatabase
  set_table_name :custom_values

  belongs_to :custom_field, :class_name => 'SourceCustomField', :foreign_key => 'custom_field_id'
  belongs_to :customized, :polymorphic => true

  def self.migrate
    all.each do |source_custom_value|
      puts "- Migrating custom value ##{source_custom_value.id}"
      attributes = RedmineMerge::Utils.hash_attributes_adapter("CustomValue",source_custom_value.attributes)

      target_custom_value = CustomValue.new(attributes) do |cv|
        cv.custom_field = CustomField.find(RedmineMerge::Mapper.get_new_custom_field_id(source_custom_value.custom_field.id))
        
        case source_custom_value.customized_type
          when "Issue"
            new_issue_id = RedmineMerge::Mapper.get_new_issue_id(source_custom_value.customized_id)
            if new_issue_id.present?
              cv.customized = Issue.find(new_issue_id)
            end
          when "Document"
            new_document_id = RedmineMerge::Mapper.get_new_document_id(source_custom_value.customized_id)
            if new_document_id.present?
              cv.customized = Document.find(new_document_id)
            end 
          when "WikiPage"
            new_wiki_page_id = RedmineMerge::Mapper.get_new_wiki_page_id(source_custom_value.customized_id)
            if new_wiki_page_id.present?
              cv.customized = WikiPage.find(new_wiki_page_id)
            end
          when "Project"
            new_project_id = RedmineMerge::Mapper.get_new_project_id(source_custom_value.customized_id)
            if new_project_id.present?
              cv.customized = Project.find(new_project_id)
            end
          when "Version"
            new_version_id = RedmineMerge::Mapper.get_new_version_id(source_custom_value.customized_id)
            if new_version_id.present?
              cv.customized = Version.find(new_version_id)
            end
          when "News"
            new_news_id = RedmineMerge::Mapper.get_new_news_id(source_custom_value.customized_id)
            if new_news_id.present?
              cv.customized = News.find(new_news_id)
            end
          when "Principal"
            new_user_id = RedmineMerge::Mapper.get_new_user_id(source_custom_value.customized_id)
            if new_user_id.present?
              cv.customized = User.find(new_user_id)
            end
        end
      end

      target_custom_value.save(false)
    end
  end
end