class SourceWikiContent < ActiveRecord::Base
  include SecondDatabase
  set_table_name :wiki_contents

  belongs_to :author, :class_name => 'SourceUser', :foreign_key => 'author_id'

  def self.migrate
    all.each do |source_wiki_content|
      puts "- Migrating wiki content ##{source_wiki_content.id}"
      attributes = RedmineMerge::Utils.hash_attributes_adapter("WikiContent",source_wiki_content.attributes)
      
      WikiContent.create!(attributes) do |wc|
        wc.page = WikiPage.find(RedmineMerge::Mapper.get_new_wiki_page_id(source_wiki_content.page_id))
        wc.author = User.find(RedmineMerge::Mapper.get_new_user_id(source_wiki_content.author.id))
      end
    end
  end
end
