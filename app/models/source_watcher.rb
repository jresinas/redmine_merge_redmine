class SourceWatcher < ActiveRecord::Base
  include SecondDatabase
  set_table_name :watchers
  belongs_to :user, :class_name => 'SourceUser'

  def self.migrate
    all.each do |source_watcher|
      puts "- Migrating watcher ##{source_watcher.id}"
      # Si la clase del tipo de seguidor no existe en el código del destino, se salta la migración del seguidor
      if RedmineMerge::Utils.class_exists?(source_watcher.watchable_type)
        attributes = RedmineMerge::Utils.hash_attributes_adapter("Watcher",source_watcher.attributes)

        target_watcher = Watcher.new(attributes) do |w|
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
        
        target_watcher.save
      else
        puts "Watchable type not found"
      end
    end
  end
end
