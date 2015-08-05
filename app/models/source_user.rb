class SourceUser < ActiveRecord::Base
  include SecondDatabase
  set_table_name :users

  has_many :members, :class_name => 'SourceMember', :foreign_key => 'user_id'
  has_one :preference, :class_name => 'SourceUserPreference', :foreign_key => 'user_id'
  has_and_belongs_to_many :users, :class_name => 'SourceUser', :join_table => 'groups_users', :foreign_key => 'group_id', :association_foreign_key => 'user_id'

  def self.migrate
    all.each do |source_user|
      puts "- Migrating user #{source_user}..."
      if source_user.type == "AnonymousUser"
        user = User.anonymous
        puts "-- Found"
      elsif source_user.type == "Group" 
        user = Group.find_by_lastname(source_user.lastname)
        
        if user.present?
          puts "-- Found Group"
        else
          user = Group.new(source_user.attributes) do |g|
          end

          user.save(false)
          puts "-- Not found, Group created"
        end

        migrate_groups_users(source_user, user.id)
      elsif source_user.type == "User"
        user = (User.find_by_mail(source_user.mail) || User.find_by_login(source_user.login)) 
        
        if user.present?
          puts "-- Found User"
        else
          user = User.new(source_user.attributes) do |u|
            u.login = source_user.login
            u.admin = source_user.admin
            u.hashed_password = source_user.hashed_password
          end

          user.save(false)
          puts "-- Not found, User created"
        end
      end
      puts "-- Added to map"
      RedmineMerge::Mapper.add_user(source_user.id, user.id)
    end
  end

  def self.migrate_groups_users(source_group, target_group_id)
    puts "-- Migrating users for group: #{source_group.lastname}"
    SourceUser.get_group_users(source_group.id).each do |source_user|
      target_user = User.find(RedmineMerge::Mapper.get_new_user_id(source_user.id))
      target_group = Group.find(target_group_id)
      target_group.users << target_user if target_user.present? and target_group.present?
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
