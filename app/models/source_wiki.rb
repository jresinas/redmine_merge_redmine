class SourceWiki < ActiveRecord::Base
  include SecondDatabase
  set_table_name :wikis

  def self.migrate
    all.each do |source_wiki|
      puts "- Migrating source wiki #{source_wiki.id}"
      project = Project.find(RedmineMerge::Mapper.get_new_project_id(source_wiki.project_id))

      attributes = RedmineMerge::Utils.hash_attributes_adapter("Wiki",source_wiki.attributes)
      wiki = Wiki.create!(attributes) do |w|
        w.project = project
      end

      RedmineMerge::Mapper.add_wiki(source_wiki.id, wiki.id)

      # Need to remove any default wikis if they exist
      if project.wiki.start_page == 'Wiki' && wiki.start_page != 'Wiki'
        project.wiki.destroy
      end
    end
  end
end
