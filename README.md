# accession_events
An ArchivesSpace plugin that creates a set of linked events for new Accessions

## How to install it

To install, just activate the plugin in your config/config.rb file by
including an entry such as:

     # If you have other plugins loaded, just add 'accession_events' to
     # the list
     AppConfig[:plugins] = ['local', 'other_plugins', 'accession_events']

And then clone the `accession_events` repository into your
ArchivesSpace plugins directory.  For example:

     cd /path/to/your/archivesspace/plugins
     git clone https://github.com/hudmol/accession_events.git

Or, if you are after a particular release, go to the releases page and
download and unzip the release you want:

     https://github.com/hudmol/accession_events/releases


## How it works

Whenever a new Accession record is created, a set of linked Event records
are automatically created.

The types of Events created and their values are set in configuration,
like this:

     AppConfig[:accession_events] = {
       :agent_username => 'admin',                                                  
       :agent_role => 'authorizer',
       :accession_role => 'source',
       :outcome => 'fail',
       :event_types => [
                        'acknowledgement_sent',
                        'agreement_sent',
                        'agreement_signed',
                        'cataloged',
                        'processed'
                       ]
     }

Note: the configuration shown in the example above is the default configuration
so if you like the way it looks there is no need to specify a configuration.

One Event will be created for each item in the `:event_types` list.
Each created Event will have properties as specified in the rest of the
configuration.

Note that `:agent_username` must be the username of a User in the system.
If you wish to use an Agent that is not a User, you will have to specify an
`:agent_uri` value like this:

     AppConfig[:accession_events] = {
       :agent_uri = '/agents/people/1',
       ...
     }

The `:agent_uri` must be a valid backend uri for an Agent in the system.

All of the configuration settings will be checked at system start up.
`:agent_username` or `:agent_uri` must refer to existing Agent records.
`:agent_role`, `:accession_role`, `:outcome`, and `:event_types` must all
contain valid values from their respective Enumerations.
