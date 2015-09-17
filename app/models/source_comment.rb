class SourceComment < ActiveRecord::Base
  include SecondDatabase
  set_table_name :comments

  belongs_to :author, :class_name => 'SourceUser', :foreign_key => 'author_id'

  def self.migrate
    all.each do |source_comment|
      puts "- Migrating comment ##{source_comment.id}"
      attributes = RedmineMerge::Utils.hash_attributes_adapter("Comment",source_comment.attributes)

      target_comment = Comment.new(attributes) do |c|
        c.author_id = RedmineMerge::Mapper.get_new_user_id(source_comment.author_id)
        
        case source_comment.commented_type
          when "News"
            if source_comment.commented_id.present?
              c.commented_id = RedmineMerge::Mapper.get_new_news_id(source_comment.commented_id)
            end
        end
      end

      target_comment.save(false)
    end
  end
end
