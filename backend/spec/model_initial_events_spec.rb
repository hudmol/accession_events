require 'spec_helper'

def stub_config(hash)
  AppConfig.stub(:[]).and_call_original
  AppConfig.stub(:has_key?).and_call_original

  AppConfig.stub(:has_key?).with(:accession_events).and_return(true)
  AppConfig.stub(:[]).with(:accession_events).and_return(hash)
end


describe 'InitialEvents mixin model' do

  it "adds events to new accessions" do
    stub_config({
                  :agent_uri => '/agents/people/1',
                  :agent_role => 'authorizer',
                  :accession_role => 'source',
                  :outcome => '',
                  :event_types => [
                                   'agreement_sent',
                                   'agreement_signed',
                                  ]
                })


    accession = Accession.create_from_json(build(:json_accession))
    events = Accession[accession[:id]].related_records(:event_link)

    events.length.should eq(2)
  end


  it "creates the events with date sub-records" do
    stub_config({
                  :agent_uri => '/agents/people/1',
                  :agent_role => 'authorizer',
                  :accession_role => 'source',
                  :outcome => '',
                  :event_types => [
                                   'agreement_sent',
                                   'agreement_signed',
                                  ]
                })


    accession = Accession.create_from_json(build(:json_accession))
    events = Accession[accession[:id]].related_records(:event_link)

    events[0].date[0].begin.should eq(Time.now.strftime("%Y-%m-%d"))
  end

end
