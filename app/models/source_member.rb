class SourceMember < ActiveRecord::Base
  include SecondDatabase
  set_table_name :members

  belongs_to :user
  belongs_to :project

  def self.migrate
    all.each do |source_member|
      target_member = Member.new(source_member.attributes) do |m|
        m.user_id = RedmineMerge::Mapper.get_new_user_id(source_member.user_id)
        m.project_id = RedmineMerge::Mapper.get_new_project_id(source_member.project_id)
      end

      target_member.save(false)
      RedmineMerge::Mapper.add_member(source_member.id, target_member.id)
    end
  end
end
