class SourceJournalDetail < ActiveRecord::Base
  include SecondDatabase
  set_table_name :journal_details

  belongs_to :journal, :class_name => 'SourceJournal', :foreign_key => 'journal_id'

  def self.migrate
    all.each do |source_journal_detail|
      puts "- Migrating journal detail ##{source_journal_detail.id} for journal ##{source_journal_detail.journal_id} "
      journal_id = RedmineMerge::Mapper.get_new_journal_id(source_journal_detail.journal_id)

      if journal_id.present?
        attributes = RedmineMerge::Utils.hash_attributes_adapter("JournalDetail",source_journal_detail.attributes)
        target_journal_detail = JournalDetail.new(attributes) do |jd|
          jd.journal = Journal.find(journal_id)

          # Actualizamos las referencias de los elementos modificados que se reflejan en los Journal
          if source_journal_detail.property == 'cf'
            jd.prop_key = RedmineMerge::Mapper.get_new_custom_field_id(source_journal_detail.prop_key.to_i)
          elsif source_journal_detail.property == 'attachment'
            jd.prop_key = RedmineMerge::Mapper.get_new_attachment_id(source_journal_detail.prop_key.to_i)
          # Para el resto de elementos, comprobamos los que terminan en '_id' y obtenemos el tipo de elemento al que hacen referencia
          elsif source_journal_detail.prop_key.include?('_id')
            # En función del atributo prop_key, indicamos la clase a la que se hace referencia
            case source_journal_detail.prop_key
            when 'parent_id'
              association_class = Issue
            when 'assigned_to_id'
              association_class = User
            else
              property_name = source_journal_detail.prop_key.to_s.gsub(/\_id$/, "").to_sym
              association = Issue.reflect_on_all_associations.detect {|a| a.name == property_name }
              association_class = association.klass if association
            end

            # Si se ha encontrado la clase asociada, se actualizan las referencias de la entrada para dicha clase
            if association_class
              jd.old_value = RedmineMerge::Mapper.find_id_by_property(association_class, source_journal_detail.old_value)
              jd.value = RedmineMerge::Mapper.find_id_by_property(association_class, source_journal_detail.value)
            end
          end
        end

        target_journal_detail.save if target_journal_detail.prop_key.present?
      end
    end
  end
end
