class RedmineMerge
  def self.migrate
    puts 'Migrating auth sources...'
    SourceAuthSource.migrate
    Mapper.get_auth_sources_map
    puts 'Migrating users...'
    SourceUser.migrate
    SourceUser.migrate_groups
    Mapper.get_users_map
    puts 'Migrating custom fields...'
    SourceCustomField.migrate
    Mapper.get_custom_fields_map
    puts 'Migrating trackers...'
    SourceTracker.migrate
    Mapper.get_trackers_map
    puts 'Migrating issue status...'
    SourceIssueStatus.migrate
    Mapper.get_issue_statuses_map
    puts 'Migrating projects...'
    SourceProject.migrate
    SourceProject.migrate_tree
    Mapper.get_projects_map
    puts 'Migrating issue priorities...'
    SourceEnumeration.migrate_issue_priorities
    puts 'Migrating time entry activities...'
    SourceEnumeration.migrate_time_entry_activities
    puts 'Migrating document categories...'
    SourceEnumeration.migrate_document_categories
    Mapper.get_enumerations_map
    puts 'Migrating versions...'
    SourceVersion.migrate
    Mapper.get_versions_map
    puts 'Migrating news...'
    SourceNews.migrate
    Mapper.get_news_map
    puts 'Migrating comments...'
    SourceComment.migrate
    puts 'Migrating issue categories...'
    SourceIssueCategory.migrate
    Mapper.get_issue_categories_map
    puts 'Migrating issues...'
    SourceIssue.migrate
    SourceIssue.migrate_tree
    Mapper.get_issues_map
    puts 'Migrating issue relations...'
    SourceIssueRelation.migrate
    puts 'Migrating documents...'
    SourceDocument.migrate
    Mapper.get_documents_map
    puts 'Migrating wikis...'
    SourceWiki.migrate
    Mapper.get_wikis_map
    puts 'Migrating wiki pages...'
    SourceWikiPage.migrate
    SourceWikiPage.migrate_tree
    Mapper.get_wiki_pages_map
    puts 'Migrating wiki contents...'
    SourceWikiContent.migrate
    puts 'Migrating attachments...'
    SourceAttachment.migrate
    Mapper.get_attachments_map
    puts 'Migrating journals...'
    SourceJournal.migrate
    Mapper.get_journals_map
    puts 'Migrating journal details...'
    SourceJournalDetail.migrate
    puts 'Migrating time entries...'
    SourceTimeEntry.migrate
    puts 'Migrating enabled modules...'
    SourceEnabledModule.migrate
    puts 'Migrating roles...'
    SourceRole.migrate
    Mapper.get_roles_map
    puts 'Migrating members...'
    SourceMember.migrate
    Mapper.get_members_map
    puts 'Migrating member roles...'
    SourceMemberRole.migrate
    Mapper.get_member_roles_map
    puts 'Migrating user preferences...'
    SourceUserPreference.migrate
    puts 'Migrating queries...'
    SourceQuery.migrate
    puts 'Migrating watchers..'
    SourceWatcher.migrate
    puts 'Migrating workflows..'
    SourceWorkflow.migrate
    puts "Migrating custom values..."
    SourceCustomValue.migrate

    if CONFIG_FILES_PATH.present?
      puts "Copying attachment files..."
      FileUtils.cp_r(CONFIG_FILES_PATH+'/.', Attachment.storage_path) # '/var/www/redmine_130/files/') #Attachment.storage_path
    end
  end

  class Utils
    # Comprueba que la clase indicada existe en el código de Redmine
    def self.class_exists?(class_name)
      eval("defined?(#{class_name}) && #{class_name}.is_a?(Class)") == true
    end

    # Adapta la estructura de los atributos pasados en el hash a los campos requeridos por la clase indicada en class_name
    def self.hash_attributes_adapter(class_name, hash)
      hash.reject{|k, v| !class_name.constantize.column_names.include? k }
    end
  end

  class Mapper
    Users = {}
    Projects = {}
    Issues = {}
    Journals = {}
    Wikis = {}
    WikiPages = {}
    Documents = {}
    Versions = {}
    CustomFields = {}
    Roles = {}
    Members = {}
    MemberRoles = {}
    News = {}
    IssueStatuses = {}
    IssueCategories = {}
    Trackers = {}
    Enumerations = {}
    AuthSources = {}
    Attachments = {}


    def self.add_user(source_id, new_id)
      Users[source_id] = new_id
    end

    def self.get_new_user_id(source_id)
      Users[source_id]
    end

    def self.add_project(source_id, new_id)
      Projects[source_id] = new_id
    end

    def self.get_new_project_id(source_id)
      Projects[source_id]
    end

    def self.add_issue(source_id, new_id)
      Issues[source_id] = new_id
    end

    def self.get_new_issue_id(source_id)
      Issues[source_id]
    end

    def self.add_journal(source_id, new_id)
      Journals[source_id] = new_id
    end

    def self.get_new_journal_id(source_id)
      Journals[source_id]
    end

    def self.add_wiki(source_id, new_id)
      Wikis[source_id] = new_id
    end

    def self.get_new_wiki_id(source_id)
      Wikis[source_id]
    end

    def self.add_wiki_page(source_id, new_id)
      WikiPages[source_id] = new_id
    end

    def self.get_new_wiki_page_id(source_id)
      WikiPages[source_id]
    end

    def self.add_document(source_id, new_id)
      Documents[source_id] = new_id
    end

    def self.get_new_document_id(source_id)
      Documents[source_id]
    end

    def self.add_version(source_id, new_id)
      Versions[source_id] = new_id
    end

    def self.get_new_version_id(source_id)
      Versions[source_id]
    end

    def self.add_custom_field(source_id, new_id)
      CustomFields[source_id] = new_id
    end

    def self.get_new_custom_field_id(source_id)
      CustomFields[source_id]
    end

    def self.add_role(source_id, new_id)
      Roles[source_id] = new_id
    end

    def self.get_new_role_id(source_id)
      Roles[source_id]
    end

    def self.add_member(source_id, new_id)
      Members[source_id] = new_id
    end

    def self.get_new_member_id(source_id)
      Members[source_id]
    end

    def self.add_member_role(source_id, new_id)
      MemberRoles[source_id] = new_id
    end

    def self.get_new_member_role_id(source_id)
      MemberRoles[source_id]
    end

    def self.add_news(source_id, new_id)
      News[source_id] = new_id
    end

    def self.get_new_news_id(source_id)
      News[source_id]
    end

    def self.add_issue_status(source_id, new_id)
      IssueStatuses[source_id] = new_id
    end

    def self.get_new_issue_status_id(source_id)
      IssueStatuses[source_id]
    end

    def self.add_issue_category(source_id, new_id)
      IssueCategories[source_id] = new_id
    end

    def self.get_new_issue_category_id(source_id)
      IssueCategories[source_id]
    end

    def self.add_tracker(source_id, new_id)
      Trackers[source_id] = new_id
    end

    def self.get_new_tracker_id(source_id)
      Trackers[source_id]
    end

    def self.add_enumeration(source_id, new_id)
      Enumerations[source_id] = new_id
    end

    def self.get_new_enumeration_id(source_id)
      Enumerations[source_id]
    end

    def self.add_auth_source(source_id, new_id)
      AuthSources[source_id] = new_id
    end

    def self.get_new_auth_source_id(source_id)
      AuthSources[source_id]
    end

    def self.add_attachment(source_id, new_id)
      Attachments[source_id] = new_id
    end

    def self.get_new_attachment_id(source_id)
      Attachments[source_id]
    end

    def self.get_users_map
      puts "Users: #{Users.inspect}"
    end

    def self.get_projects_map
      puts "Projects: #{Projects.inspect}"
    end

    def self.get_issues_map
      puts "Issues: #{Issues.inspect}"
    end

    def self.get_journals_map
      puts "Journals: #{Journals.inspect}"
    end

    def self.get_wikis_map
      puts "Wikis: #{Wikis.inspect}"
    end

    def self.get_wiki_pages_map
      puts "WikiPages: #{WikiPages.inspect}"
    end

    def self.get_documents_map
      puts "Documents: #{Documents.inspect}"
    end

    def self.get_versions_map
      puts "Versions: #{Versions.inspect}"
    end

    def self.get_custom_fields_map
      puts "CustomFields: #{CustomFields.inspect}"
    end

    def self.get_roles_map
      puts "Roles: #{Roles.inspect}"
    end

    def self.get_members_map
      puts "Members: #{Members.inspect}"
    end

    def self.get_member_roles_map
      puts "MemberRoles: #{MemberRoles.inspect}"
    end

    def self.get_news_map
      puts "News: #{News.inspect}"
    end

    def self.get_issue_statuses_map
      puts "IssueStatuses: #{IssueStatuses.inspect}"
    end

    def self.get_issue_categories_map
      puts "IssueCategories: #{IssueCategories.inspect}"
    end

    def self.get_trackers_map
      puts "Trackers: #{Trackers.inspect}"
    end

    def self.get_enumerations_map
      puts "Enumerations: #{Enumerations.inspect}"
    end

    def self.get_auth_sources_map
      puts "AuthSources: #{AuthSources.inspect}"
    end

    def self.get_attachments_map
      puts "Attachments: #{Attachments.inspect}"
    end

    def self.find_id_by_property(target_klass, source_id)
      # Similar to issues_helper.rb#show_detail
      source_id = source_id.to_i

      case target_klass.to_s
      when 'Project'
        return Mapper.get_new_project_id(source_id)
      when 'IssueStatus'
        target = find_target_record_from_source(SourceIssueStatus, IssueStatus, :name, source_id)
        return target.id if target
        return nil
      when 'Tracker'
        target = find_target_record_from_source(SourceTracker, Tracker, :name, source_id)
        return target.id if target
        return nil
      when 'User'
        target = find_target_record_from_source(SourceUser, User, :login, source_id)
        return target.id if target
        return nil
      when 'Enumeration'
        target = find_target_record_from_source(SourceEnumeration, Enumeration, :name, source_id)
        return target.id if target
        return nil
      when 'IssuePriority'
        target = IssuePriority.find(RedmineMerge::Mapper.get_new_enumeration_id(source_id))
        return target.id if target
        return nil
      when 'IssuePriority'
        target = IssuePriority.find(RedmineMerge::Mapper.get_new_enumeration_id(source_id))
        return target.id if target
        return nil
      when 'TimeEntryActivity'
        target = TimeEntryActivity.find(RedmineMerge::Mapper.get_new_enumeration_id(source_id))
        return target.id if target
        return nil
      when 'DocumentCategory'
        target = DocumentCategory.find(RedmineMerge::Mapper.get_new_enumeration_id(source_id))
        return target.id if target
        return nil
      when 'IssueCategory'
        source = SourceIssueCategory.find_by_id(source_id)
        return nil unless source
        target = IssueCategory.find_by_name_and_project_id(source.name, RedmineMerge::Mapper.get_new_project_id(source.project_id))
        return target.id if target
        return nil
      when 'Version'
        source = SourceVersion.find_by_id(source_id)
        return nil unless source
        target = Version.find_by_name_and_project_id(source.name, RedmineMerge::Mapper.get_new_project_id(source.project_id))
        return target.id if target
        return nil
      end
      
    end

    private

    # Utility method to dynamically find the target records
    def self.find_target_record_from_source(source_klass, target_klass, field, source_id)
      source = source_klass.find_by_id(source_id)
      field = field.to_sym
      if source
        return target_klass.find(:first, :conditions => {field => source.read_attribute(field) })
      else
        return nil
      end
    end
  end

  class Merger
=begin
    # Permite forzar la unificación de un elemento del origen con otro del destino, indicando sus nombres
    # Nombre origen => Nombre destino
    ElementsToMerge = {
      'custom_field' => {
        'Searchable field' => 'Email'
      },
      'issue_priority' => {
        'Urgent' => 'Urgente',
        'Alta' => 'High'
      },
      'time_entry_activity' => {
        'Design' => 'Diseño',
        'Development' => 'Desarrollo'
      },
      'document_category' => {
        'User documentation' => 'Documentación de usuario'
      },
      'issue_status' => {
        'Rejected' => 'Rechazado'
      },
      'tracker' => {
        #'Bug' => 'Errores'
      }
    }

    ElementsToRename = {
      # Permite renombrar un elemento del origen
      # Nombre original => Nombre final
      'custom_field' => {
        'Development status' => 'Origen RM-Servicios'
      },
      'issue_priority' => {
        'Immediate' => 'Now!',
        'Mínima' => 'Low',
        'Inmediata' => 'Low'
      },
      'time_entry_activity' => {
        'Inactive Activity' => 'What?'
      },
      'document_category' => {
        'Uncategorized' => 'Unknown',
        'Inactive Document Category' => 'What document?'
      },
      'issue_status' => {
        'Rechazada' => 'Rechazado'
      },
      'tracker' => {
        #'Feature request' => 'Mejoras solicitadas'
      }
    }
=end
#    ElementsToMerge = CONFIG_ELEMENTS_TO_MERGE
    ElementsToRename = CONFIG_ELEMENTS_TO_RENAME
=begin
    def self.find_element_to_merge(type, row, value)
      if ElementsToMerge[type].present? and ElementsToMerge[type][value].present?
        type.camelize.constantize.find(:first, :conditions => [row+' = ?', ElementsToMerge[type][value]])
      else
        type.camelize.constantize.find(:first, :conditions => [row+' = ?', value])
      end
    end
=end
    def self.check_element_to_rename(type, value)
      if ElementsToRename[type].present? and ElementsToRename[type][value].present?
        ElementsToRename[type][value]
      else
        value
      end
    end

    def self.get_user_to_merge(source)
      User.find_by_mail(source.mail)
    end

    def self.get_group_to_merge(source)
      Group.find_by_lastname(source.lastname)
    end

    def self.get_auth_source_to_merge(source)
      AuthSource.find_by_name(source.name)
    end

    def self.get_issue_category_to_merge(source)
      IssueCategory.find_by_name(source.name)
    end

    def self.get_project_to_merge(source)
      Project.find_by_identifier(source.identifier)
    end

    def self.get_role_to_merge(source)
      Role.find_by_name(source.name)
    end

    def self.get_user_preference_to_merge(source)
      UserPreference.find_by_user_id(source)
    end

    def self.get_custom_field_to_merge(source)
      CustomField.find_by_name_and_type(source.name, source.type)
    end

    def self.get_enumeration_to_merge(source)
      case source.type
        when 'IssuePriority'
          IssuePriority.find_by_name_and_type(source.name, source.type)
        when 'TimeEntryActivity'
          TimeEntryActivity.find_by_name_and_type(source.name, source.type)
        when 'DocumentCategory'
          DocumentCategory.find_by_name_and_type(source.name, source.type)
        else
          Enumeration.find_by_name_and_type(source.name, source.type)
      end
    end

    def self.get_tracker_to_merge(source)
      Tracker.find_by_name(source.name)
    end

    def self.get_issue_status_to_merge(source)
      IssueStatus.find_by_name(source.name)
    end

  end
end
