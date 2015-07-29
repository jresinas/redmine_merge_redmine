class SourceUser < ActiveRecord::Base
  include SecondDatabase
  set_table_name :users

  has_many :members

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
end
