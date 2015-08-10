class SourceComment < ActiveRecord::Base
  include SecondDatabase
  set_table_name :comments

  belongs_to :author, :class_name => 'SourceUser', :foreign_key => 'author_id'

  def self.migrate
    all.each do |source_comment|
      Comment.new(source_comment.attributes) do |c|
        c.author_id = RedmineMerge::Mapper.get_new_user_id(source_comment.author_id)

        case source_comment.commented_type
          when "News"
            c.commented_id = RedmineMerge::Mapper.get_new_news_id(source_comment.commented_id)
        end
        c.save
      end
    end
  end
end
