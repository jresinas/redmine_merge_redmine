class SourceWatcher < ActiveRecord::Base
  include SecondDatabase
  set_table_name :watchers
  belongs_to :user

  def self.migrate
    all.each do |source_watcher|
      Watcher.create!(source_watcher.attributes) do |w|
        w.user_id = RedmineMerge::Mapper.get_new_user_id(source_watcher.user_id)
        case source_watcher.watchable_type
          when 'Issue'
            w.watchable_id = RedmineMerge::Mapper.get_new_issue_id(source_watcher.watchable_id)
          when 'News'
            w.watchable_id = RedmineMerge::Mapper.get_new_news_id(source_watcher.watchable_id)
          when 'Wiki'
            w.watchable_id = RedmineMerge::Mapper.get_new_wiki_id(source_watcher.watchable_id)
          when 'WikiPage'
            w.watchable_id = RedmineMerge::Mapper.get_new_wiki_page_id(source_watcher.watchable_id)
        end
      end
    end
  end
end
