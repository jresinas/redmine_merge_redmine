class SourceUserPreference < ActiveRecord::Base
  include SecondDatabase
  set_table_name :user_preferences

  belongs_to :user, :class_name => 'SourceUser'

  def self.migrate
    all.each do |source_user_preference|
      puts "- Migrating user preference ##{source_user_preference.id} for user ##{source_user_preference.user_id}"
      user_id = RedmineMerge::Mapper.get_new_user_id(source_user_preference.user_id)
      target_user_preference = RedmineMerge::Merger.get_user_preference_to_merge(user_id)

      if !target_user_preference.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("UserPreference",source_user_preference.attributes)
        target_user_preference = UserPreference.new(attributes) do |up|
          up.user_id = user_id
          up.others = source_user_preference.others
        end

        target_user_preference.save(false)
      end
    end
  end
end
