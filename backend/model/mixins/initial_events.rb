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
          "outcome" => cfg[:outcome],
          "timestamp" => time_now,
          "linked_records" => [
                               {
                                 "role" => cfg[:accession_role],
                                 "ref" => JSONModel(:accession).uri_for(obj.id, :repo_id => RequestContext.get(:repo_id))
                               },
                              ],
          "linked_agents" => [
                              {"role" => cfg[:agent_role], "ref" => cfg[:agent_uri]}
                             ]
        }

        Event.create_from_json(JSONModel(:event).from_hash(event),
                               :system_generated => true)
      end

    end

  end

end
