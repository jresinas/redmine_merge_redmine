class SourceCustomValue < ActiveRecord::Base
  include SecondDatabase
  set_table_name :custom_values

  belongs_to :custom_field, :class_name => 'SourceCustomField', :foreign_key => 'custom_field_id'
  belongs_to :customized, :polymorphic => true

  def self.migrate
    all.each do |source_custom_value|
      CustomValue.new(source_custom_value.attributes) do |cv|
        cv.custom_field = CustomField.find_by_name(source_custom_value.custom_field.name)
        case source_custom_value.customized_type
                      when "Issue"
                        cv.customized = Issue.find RedmineMerge::Mapper.get_new_issue_id(source_custom_value.customized_id)
                      when "Document"
                        cv.customized = Document.find RedmineMerge::Mapper.get_new_document_id(source_custom_value.customized_id)
                      when "WikiPage"
                        cv.customized = WikiPage.find RedmineMerge::Mapper.get_new_wiki_page_id(source_custom_value.customized_id)
                      when "Project"
                        cv.customized = Project.find RedmineMerge::Mapper.get_new_project_id(source_custom_value.customized_id)
                      when "Version"
                        cv.customized = Version.find RedmineMerge::Mapper.get_new_version_id(source_custom_value.customized_id)
                      when "News"
                        cv.customized = News.find RedmineMerge::Mapper.get_new_news_id(source_custom_value.customized_id)
                      end
        cv.save
      end
    end
  end
end