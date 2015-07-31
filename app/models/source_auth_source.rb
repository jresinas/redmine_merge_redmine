class SourceAuthSource < ActiveRecord::Base
  include SecondDatabase
  set_table_name :auth_sources

  def self.migrate
    all.each do |source_auth_source|
      target_auth_source = AuthSource.find_by_name(source_auth_source.name)

      if !target_auth_source.present?
        AuthSource.create!(source_auth_source.attributes) do |as|
          # Type must be set explicitly -- not included in the attributes
          as.type = source_auth_source.type
        end
      end
    end
  end
end
