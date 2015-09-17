class SourceDocument < ActiveRecord::Base
  include SecondDatabase
  set_table_name :documents

  belongs_to :category, :class_name => 'SourceEnumeration', :foreign_key => 'category_id'

  def self.migrate
    all.each do |source_document|
      puts "- Migrating document ##{source_document.id}: #{source_document.title}"
      attributes = RedmineMerge::Utils.hash_attributes_adapter("Document",source_document.attributes)

      target_document = Document.new(attributes) do |d|
        d.project = Project.find(RedmineMerge::Mapper.get_new_project_id(source_document.project_id))

        if source_document.category_id.present?
          d.category = DocumentCategory.find(RedmineMerge::Mapper.get_new_enumeration_id(source_document.category.id))
        end
      end

      target_document.save(false)
      RedmineMerge::Mapper.add_document(source_document.id, target_document.id)
    end
  end
end
