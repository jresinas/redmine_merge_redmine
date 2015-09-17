class SourceUser < ActiveRecord::Base
  include SecondDatabase
  set_table_name :users

  has_many :members, :class_name => 'SourceMember', :foreign_key => 'user_id'
  has_one :preference, :class_name => 'SourceUserPreference', :foreign_key => 'user_id'
  has_and_belongs_to_many :users, :class_name => 'SourceUser', :join_table => 'groups_users', :foreign_key => 'group_id', :association_foreign_key => 'user_id'

  def self.migrate
    all.each do |source_user|
      puts "- Migrating user ##{source_user.id}: #{source_user}"
      if source_user.type == "AnonymousUser"
        user = User.anonymous
        puts "-- Found"
      elsif source_user.type == "Group" 
        user = RedmineMerge::Merger.get_group_to_merge(source_user)
        
        if user.present?
          puts "-- Found Group"
        else
          attributes = RedmineMerge::Utils.hash_attributes_adapter("Group",source_user.attributes)
          user = Group.new(attributes)

          user.save(false)
          puts "-- Not found, Group created"
        end
      elsif source_user.type == "User"
        user = RedmineMerge::Merger.get_user_to_merge(source_user)
        
        if user.present?
          puts "-- Found User"
        else
          attributes = RedmineMerge::Utils.hash_attributes_adapter("User",source_user.attributes)
          user = User.new(attributes) do |u|
            u.login = source_user.login
            u.admin = source_user.admin
            u.hashed_password = source_user.hashed_password
            if source_user.auth_source_id.present?
              u.auth_source_id = RedmineMerge::Mapper.get_new_auth_source_id(source_user.auth_source_id)
            end
          end

          user.save(false)
          puts "-- Not found, User created"
        end
      end

      RedmineMerge::Mapper.add_user(source_user.id, user.id)
      puts "-- Added to map"
    end
  end

  # Migración de los grupos de usuario
  def self.migrate_groups
    all.each do |source_group|
      if source_group.type == "Group"
        target_group = Group.find(RedmineMerge::Mapper.get_new_user_id(source_group.id))
        migrate_groups_users(source_group, target_group)
      end
    end
  end

  # Registrar usuarios pertenecientes al grupo 
  def self.migrate_groups_users(source_group, target_group)
    puts "-- Migrating users for group: #{source_group.lastname}"
    SourceUser.get_group_users(source_group.id).each do |source_user|
      target_user = User.find(RedmineMerge::Mapper.get_new_user_id(source_user.id))
      target_group.users << target_user if target_user.present? and target_group.present? and !target_group.users.collect{|u| u.id}.include?(target_user.id)
    end
  end

  private
  # Obtiene los usuarios que pertenecen a un grupo en la BBDD de origen
  def self.get_group_users(group_id)
    users = []
    if group_id.present?
      group = SourceUser.find(group_id)
      if group.present? and group.type == 'Group'
        users = SourceUser.find_by_sql "SELECT * FROM users AS u LEFT JOIN groups_users AS gu ON gu.user_id = u.id WHERE gu.group_id="+group_id.to_s
      end
    end

    users
  end
end
