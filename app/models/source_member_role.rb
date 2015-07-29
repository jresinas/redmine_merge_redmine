class SourceMemberRole < ActiveRecord::Base
  include SecondDatabase
  set_table_name :member_roles

  belongs_to :member
  belongs_to :role

  def self.migrate
    all.each do |source_member_role|
      target_member_role = MemberRole.new(source_member_role.attributes) do |mr|
        mr.member_id = RedmineMerge::Mapper.get_new_member_id(source_member_role.member_id)
        mr.role_id = RedmineMerge::Mapper.get_new_role_id(source_member_role.role_id)
        mr.inherited_from = RedmineMerge::Mapper.get_new_member_role_id(source_member_role.inherited_from)
      end

      target_member_role.save
      RedmineMerge::Mapper.add_member_role(source_member_role.id, target_member_role.id)
    end
  end
end
