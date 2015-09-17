class SourceMemberRole < ActiveRecord::Base
  include SecondDatabase
  set_table_name :member_roles

  belongs_to :member, :class_name => 'SourceMember'
  belongs_to :role, :class_name => 'SourceRole'

  def self.migrate
    all.each do |source_member_role|
      puts "- Migrating member role ##{source_member_role.id}"

      # Los elementos heredados de grupos miembros, son creados automáticamente cuando se establece la membresía del grupo al que pertenece (en SourceUser#migrate_groups_users)
      if !source_member_role.inherited_from.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("MemberRole",source_member_role.attributes)

        target_member_role = MemberRole.new(attributes) do |mr|
          mr.member_id = RedmineMerge::Mapper.get_new_member_id(source_member_role.member_id)
          mr.role_id = RedmineMerge::Mapper.get_new_role_id(source_member_role.role_id)
          mr.inherited_from = RedmineMerge::Mapper.get_new_member_role_id(source_member_role.inherited_from)
        end

        target_member_role.save
        RedmineMerge::Mapper.add_member_role(source_member_role.id, target_member_role.id)
      end
    end
  end
end
