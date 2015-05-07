# At start up we need to make sure the plugin is configured correctly

# This is a full set of default config values based on NLA's requirements
config_defaults = {
  :agent => 'admin',
  :agent_role => 'authorizer',
  :accession_role => 'source',
  :outcome => '',
  :event_types => [
                   'acknowledgement_sent',
                   'agreement_sent',
                   'agreement_signed',
                   'cataloged',
                   'processed'
                  ]
}

# No config is required, so here we initialize the config if it's absent
AppConfig[:accession_events] = {} unless AppConfig.has_key?(:accession_events)

# And here we apply the config to override the defaults
AppConfig[:accession_events] = config_defaults.merge(AppConfig[:accession_events])


###
# The rest of this is checking the config

# many of the config values are enum values
# this def checks that a configured value is in the enum
def check_enum_value(cfg_name, enum_name, value)
  enum = Enumeration[:name => enum_name]
  if EnumerationValue.filter(:enumeration_id => enum.id).all.select { |ev| ev.value == value }.empty?
    raise "#{cfg_name} '#{value}' provided in accession_events configuration does not exist"
  end
end


cfg = AppConfig[:accession_events]

# check agent
user = User[:username => cfg[:agent]]
if user.nil?
  raise "username '#{cfg[:agent]}' doesn't exist for agent in accession_events configuration"
end
# remember the agent_uri so we don't have to look it up again
cfg[:agent_uri] = JSONModel::JSONModel(:agent_person).uri_for(user.agent_record_id)

# check agent_role
check_enum_value('agent_role', 'linked_agent_event_roles', cfg[:agent_role])

# check accession_role
check_enum_value('accession_role', 'linked_event_archival_record_roles', cfg[:accession_role])

# check outcome
check_enum_value('outcome', 'event_outcome', cfg[:outcome]) unless cfg[:outcome].empty?

# check event_types
enum = EnumerationValue.filter(:enumeration_id => Enumeration[:name => 'event_event_type'].id).all
bad_event_types = []
cfg[:event_types].each do |type|
  bad_event_types << type if enum.select { |ev| ev.value == type }.empty?
end
if bad_event_types.length == 1
  raise "event_type '#{bad_event_types.first}' provided in accession_events configuration does not exist"
elsif bad_event_types.length > 1
  raise "event_types '#{bad_event_types.join(', ')}' provided in accession_events configuration do not exist"
end

# All done
Log.info "The accession_events plugin is configured correctly. Good job!"
