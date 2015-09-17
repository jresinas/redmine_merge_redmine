class SourceMember < ActiveRecord::Base
  include SecondDatabase
  set_table_name :members

  belongs_to :user, :class_name => 'SourceUser'
  belongs_to :project, :class_name => 'SourceProject'

  def self.migrate
    all.each do |source_member|
      puts "- Migrating member ##{source_member.id} "
=begin
atributos = source_member.attributes
atributos.delete("from_date")
atributos.delete("to_date")
atributos.delete("allocation")
target_member = Member.new(atributos) do |m|
  puts "creando"
=end
      attributes = RedmineMerge::Utils.hash_attributes_adapter("Member",source_member.attributes)
      target_member = Member.new(attributes) do |m|
        m.user_id = RedmineMerge::Mapper.get_new_user_id(source_member.user_id)
        m.project_id = RedmineMerge::Mapper.get_new_project_id(source_member.project_id)
      end
puts "#{target_member.inspect}"

      existing_member = Member.find_by_user_id_and_project_id(target_member.user_id, target_member.project_id)
      if !existing_member.present?
        target_member.save(false)
      else
        target_member = existing_member
      end

      RedmineMerge::Mapper.add_member(source_member.id, target_member.id)
    end
  end
end
