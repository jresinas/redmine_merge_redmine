class SourceAttachment < ActiveRecord::Base
  include SecondDatabase
  set_table_name :attachments

  belongs_to :author, :class_name => 'SourceUser', :foreign_key => 'author_id'

  def self.migrate
    all.each do |source_attachment|
      if source_attachment.container_type.present? and source_attachment.container_id.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("Attachment",source_attachment.attributes)

        target_attachment = Attachment.new(attributes) do |a|
          a.author = User.find(RedmineMerge::Mapper.get_new_user_id(source_attachment.author.id)) if source_attachment.author_id.present?
          case source_attachment.container_type
            when "Issue"
              a.container = Issue.find RedmineMerge::Mapper.get_new_issue_id(source_attachment.container_id)
            when "Document"
              a.container = Document.find RedmineMerge::Mapper.get_new_document_id(source_attachment.container_id)
            when "WikiPage"
              a.container = WikiPage.find RedmineMerge::Mapper.get_new_wiki_page_id(source_attachment.container_id)
            when "Project"
              a.container = Project.find RedmineMerge::Mapper.get_new_project_id(source_attachment.container_id)
            when "Version"
              a.container = Version.find RedmineMerge::Mapper.get_new_version_id(source_attachment.container_id)
          end
        end

        target_attachment.save(false)
        RedmineMerge::Mapper.add_attachment(source_attachment.id, target_attachment.id)
      end
    end
  end
end
