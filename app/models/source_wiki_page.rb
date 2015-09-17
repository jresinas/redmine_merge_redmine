class SourceWikiPage < ActiveRecord::Base
  include SecondDatabase
  set_table_name :wiki_pages

  def self.migrate
    all(:order => 'parent_id ASC').each do |source_wiki_page|
      puts "- Migrating wiki page ##{source_wiki_page.id}"
      if source_wiki_page.wiki_id.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("WikiPage",source_wiki_page.attributes)

        target_wiki_page = WikiPage.new(attributes) do |wp|
          wp.wiki = Wiki.find(RedmineMerge::Mapper.get_new_wiki_id(source_wiki_page.wiki_id))
        end

        target_wiki_page.save(false)
        RedmineMerge::Mapper.add_wiki_page(source_wiki_page.id, target_wiki_page.id)
      end
    end
  end

  def self.migrate_tree
    WikiPage.record_timestamps = false
    all.each do |source_wiki_page|
      target_wiki_page = WikiPage.find(RedmineMerge::Mapper.get_new_wiki_page_id(source_wiki_page.id))

      target_wiki_page[:parent_id] = RedmineMerge::Mapper.get_new_wiki_page_id(source_wiki_page.parent_id) if source_wiki_page.parent_id.present?

      target_wiki_page.save(false)
    end
    WikiPage.record_timestamps = true
  end
end
