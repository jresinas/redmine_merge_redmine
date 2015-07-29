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
      elsif user = (User.find_by_mail(source_user.mail) || User.find_by_login(source_user.login)) 
        puts "-- Found"
      else
        user = User.new(source_user.attributes) do |u|
          u.login = source_user.login
          u.admin = source_user.admin
          u.hashed_password = source_user.hashed_password
        end
        user.save(false)
        puts "-- Not found, created"
      end
      puts "-- Added to map"
      RedmineMerge::Mapper.add_user(source_user.id, user.id)
    end
  end
end
