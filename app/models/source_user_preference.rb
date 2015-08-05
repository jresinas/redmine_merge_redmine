class SourceUserPreference < ActiveRecord::Base
  include SecondDatabase
  set_table_name :user_preferences

  belongs_to :user, :class_name => 'SourceUser'

  def self.migrate
    all.each do |source_user_preference|
      user_id = RedmineMerge::Mapper.get_new_user_id(source_user_preference.user_id)

      if !UserPreference.find_by_user_id(user_id).present?
        target_user_preference = UserPreference.new(source_user_preference.attributes) do |up|
          up.user_id = user_id
          up.others = source_user_preference.others
        end

        target_user_preference.save
      end
    end
  end
end
