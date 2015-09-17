class SourceAuthSource < ActiveRecord::Base
  include SecondDatabase
  set_table_name :auth_sources

  def self.migrate
    all.each do |source_auth_source|
      puts "- Migrating auth source ##{source_auth_source.id}: #{source_auth_source.name}"
      target_auth_source = RedmineMerge::Merger.get_auth_source_to_merge(source_auth_source)

      if !target_auth_source.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("AuthSource",source_auth_source.attributes)
        target_auth_source = AuthSource.create!(attributes) do |as|
          # Type must be set explicitly -- not included in the attributes
          as.type = source_auth_source.type
        end
      end

      RedmineMerge::Mapper.add_auth_source(source_auth_source.id, target_auth_source.id)
    end
  end
end
