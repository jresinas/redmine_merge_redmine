class SourceNews < ActiveRecord::Base
  include SecondDatabase
  set_table_name :news

  belongs_to :author, :class_name => 'SourceUser', :foreign_key => 'author_id'

  def self.migrate
    all.each do |source_news|
      puts source_news.attributes.inspect
      target_news = News.new(source_news.attributes) do |n|
        map_prj = RedmineMerge::Mapper.get_new_project_id(source_news.project_id)
        map_usr = RedmineMerge::Mapper.get_new_user_id(source_news.author.id)

        if map_prj.present? and map_usr.present?
          n.project = Project.find(map_prj)
          n.author = User.find(map_usr)
        end
      end
      target_news.save(false)
      RedmineMerge::Mapper.add_news(source_news.id, target_news.id)
    end
  end
end
