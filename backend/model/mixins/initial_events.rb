module InitialEvents

  def self.included(base)
    base.extend(ClassMethods)
  end


  module ClassMethods

    def create_from_json(json, opts = {})
      obj = super

      create_events_for(obj)

      obj
    end


    def create_events_for(obj)
      cfg = AppConfig[:accession_events]
      time_now = Time.now.utc.iso8601

      cfg[:event_types].each do |type|
        event = {
          "event_type" => type,
          "timestamp" => time_now,
          "linked_records" => [
                               {
                                 "role" => cfg[:accession_role],
                                 "ref" => JSONModel(:accession).uri_for(obj.id, :repo_id => RequestContext.get(:repo_id))
                               },
                              ],
          "linked_agents" => [
                              {"role" => cfg[:agent_role], "ref" => agent_uri}
                             ]
        }

        Event.create_from_json(JSONModel(:event).from_hash(event),
                               :system_generated => true)
      end

    end


    def agent_uri
      AppConfig[:accession_events][:agent_uri] ||= 
        JSONModel::JSONModel(:agent_person).uri_for(User[:username => AppConfig[:accession_events][:agent]].agent_record_id)
    end

  end

end
