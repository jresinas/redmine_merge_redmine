class SourceQuery < ActiveRecord::Base
  include SecondDatabase
  set_table_name :queries

  belongs_to :project, :class_name => 'SourceProject'
  belongs_to :user, :class_name => 'SourceUser'

  def self.migrate
    all.each do |source_query|
      puts "- Migrating query ##{source_query.id}"

      if !source_query.sort_criteria.present?
        source_query.sort_criteria = []
      end

      attributes = RedmineMerge::Utils.hash_attributes_adapter("Query",source_query.attributes)
      target_query = Query.new(attributes) do |q|
        q.project_id = RedmineMerge::Mapper.get_new_project_id(source_query.project_id) if source_query.project_id.present?
        q.user_id = RedmineMerge::Mapper.get_new_user_id(source_query.user_id)
        q[:sort_criteria] = source_query.sort_criteria
        q[:sort_criteria] = nil if !q.sort_criteria.present?
      end

      target_query.save
    end
  end
end
