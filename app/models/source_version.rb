class SourceVersion < ActiveRecord::Base
  include SecondDatabase
  set_table_name :versions

  def self.migrate
    all.each do |source_version|
      version = Version.new(source_version.attributes) do |v|
        map_prj = RedmineMerge::Mapper.get_new_project_id(source_version.project_id)
        if map_prj.present?
          v.project = Project.find(map_prj)
        end
      end
      version.save(false)

      RedmineMerge::Mapper.add_version(source_version.id, version.id)
    end
  end
end
