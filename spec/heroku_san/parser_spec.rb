require 'spec_helper'

describe HerokuSan::Parser do
  let(:parser) { subject }

  Parseable = Struct.new(:config_file, :configuration)
  describe '#parse' do
    context 'using the new format' do
      let(:parseable) { Parseable.new.tap do |mock| mock.config_file = File.join(SPEC_ROOT, "fixtures", "example.yml") end }
      it "returns a list of apps" do
        parser.parse(parseable)
        parseable.configuration.keys.should =~ %w[production staging demo]
        parseable.configuration['production'].should == {
            'app' => 'awesomeapp',
            'tag' => 'production/*',
            'config' => {
                'BUNDLE_WITHOUT' => 'development:test',
                'GOOGLE_ANALYTICS' => 'UA-12345678-1'
            }
        }
        parseable.configuration['staging'].should == {
            'app' => 'awesomeapp-staging',
            'stack' => 'bamboo-ree-1.8.7',
            'config' => {
                'BUNDLE_WITHOUT' => 'development:test'
            }
        }
        parseable.configuration['demo'].should == {
            'app' => 'awesomeapp-demo',
            'stack' => 'cedar',
            'config' => {
                'BUNDLE_WITHOUT' => 'development:test'
            }
        }
      end

    end
    context "using the old heroku_san format" do
      let(:parseable) { Parseable.new.tap do |mock| mock.config_file = File.join(SPEC_ROOT, "fixtures", "old_format.yml") end }
      it "returns a list of apps" do
        parser.parse(parseable)
        parseable.configuration.keys.should =~ %w[production staging demo]
        parseable.configuration.should == {
            'production' => {'app' => 'awesomeapp', 'config' => {}},
            'staging' => {'app' => 'awesomeapp-staging', 'config' => {}},
            'demo' => {'app' => 'awesomeapp-demo', 'config' => {}}
        }
      end
    end
  end
end