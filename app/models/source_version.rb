class SourceVersion < ActiveRecord::Base
  include SecondDatabase
  set_table_name :versions

  def self.migrate
    all.each do |source_version|
      puts "- Migrating version ##{source_version.id}"
      attributes = RedmineMerge::Utils.hash_attributes_adapter("Version",source_version.attributes)

      target_version = Version.new(attributes) do |v|
        map_prj = RedmineMerge::Mapper.get_new_project_id(source_version.project_id)
        if map_prj.present?
          v.project = Project.find(map_prj)
        end
      end

      target_version.save(false)
      RedmineMerge::Mapper.add_version(source_version.id, target_version.id)
    end
  end
end
