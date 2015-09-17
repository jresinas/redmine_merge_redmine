class SourceJournal < ActiveRecord::Base
  include SecondDatabase
  set_table_name :journals

  belongs_to :journalized, :polymorphic => true
  belongs_to :issue, :class_name => 'SourceIssue', :foreign_key => :journalized_id
  has_many :details, :class_name => "SourceJournalDetail"

  def self.migrate
    all.each do |source_journal|
      puts "- Migrating journal ##{source_journal.id} (#{source_journal.journalized_type}) "

      # Si la clase del tipo de nota no existe en el código del destino, se salta la migración de la nota
      if source_journal.journalized_id.present? and RedmineMerge::Utils.class_exists?(source_journal.journalized_type)
        attributes = RedmineMerge::Utils.hash_attributes_adapter("Journal",source_journal.attributes)
        target_journal = Journal.new(attributes)

        # Si es la nota es para una tarea (el único tipo conocido), obtenemos la id de la tarea en la BBDD de destino
        if source_journal.journalized_type == "Issue"
          new_journalized_id = RedmineMerge::Mapper.get_new_issue_id(source_journal.journalized_id)
          puts "-- Journal for issue ##{source_journal.issue.id}: #{source_journal.issue.subject}" if new_journalized_id.present?
        else
          new_journalized_id = source_journal.journalized_id
          puts "-- Journal for #{source_journal.journalized_type} ##{source_journal.journalized.id}"
        end

        if new_journalized_id.present?
          target_journal.journalized_id = new_journalized_id
          target_journal.user_id = RedmineMerge::Mapper.get_new_user_id(source_journal.user_id)

          if target_journal.notes.blank?
            notes = target_journal.notes
            target_journal.notes = "-"
            target_journal.save
            target_journal.notes = notes
            target_journal.send(:update_without_callbacks)
          else
            target_journal.save
          end

          RedmineMerge::Mapper.add_journal(source_journal.id, target_journal.id)
        end    
      elsif !RedmineMerge::Utils.class_exists?(source_journal.journalized_type)
        puts "-- Journal type not found"
      elsif !source_journal.journalized_id.present?
        puts "-- Journalized element not found"
      end
    end
  end
end
