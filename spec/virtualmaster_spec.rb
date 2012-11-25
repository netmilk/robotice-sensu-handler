require File.join(File.dirname(__FILE__),'spec_helper.rb')

describe VirtualmasterHandler do
  #TODO: DRY it! duplicite code in redmine_spec.rb
  def valid_issue
    {
      "issue" => {
        "project_id" => 'virtualmaster-infrastructure',
        "subject" => 'c1.sit.vmin.cz disk_srv',
        "description" => 'c1.sit.vmin.cz disk_srv DISK CRITICAL - free space: / 114 MB (6% inode=56%);| /=1624MB;;1556;0;1831',
        "priority_id" => '4'
      }
    }
  end

  describe "handler instance" do
    before do
      # mock sending xmpp messages globally
      Xmpp.any_instance.stub(:send_message).and_return(true)
    end

    subject{ VirtualmasterHandler.new }

    it{should respond_to(:xmpp_message)}
    it{should respond_to(:errors)}
    it{should respond_to(:redmine)}
    it{should respond_to(:issue)}

    describe "#handle" do
      before do
        # stubbing web requests
        stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld").
        to_return(:status => 200, :body => "", :headers => {})
        stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld/frontend_http_check").
        to_return(:status => 200, :body => "", :headers => {})

        Redmine.any_instance.stub(:create_issue).and_return(valid_issue)

        SensuRedis.any_instance.stub(:update_event_redmine_issue_url)
          .and_return(true)

      end

      context "event JSON doesn't contain 'custom_data' key" do 
        it "should raise version error"
      end

      it "should create Foreman lookup" do
        Foreman.any_instance.should_receive(:query_host).with('node1.domain.tld')
        handle event_mock("without_redmine_issue")
      end


      context "Foreman raises error" do
        before do
          stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
          to_timeout
        end
        subject{handle event_mock('without_redmine_issue')}

        it "should create error message" do
          subject.errors.length.should eq(1)
        end

        it "should notify new error" do
          ErrorHandler.any_instance.should_receive(:handle)
          handle event_mock('without_redmine_issue')
        end
      end

      context "Foreman responds correctly" do
        before do
          stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
          to_return(mock_response('foreman/valid_response'))
          @handler = handle event_mock('without_redmine_issue')
        end

        context "host does not exist in foreman or exists without metadata" do
          it "should create some low priority to request resolution of this situation"
        end

        context "host exists in foreman and has metadata" do
          context "Redmine is available" do
            before do
              Redmine.any_instance.stub(:send_issue).with(valid_issue)
            end

            context "event JSON key 'custom_data' contains key 'redmine_issue'" do 
              it "should NOT create new Redmine issue" do
                Redmine.any_instance.should_not_receive(:create_issue)
                handle event_mock('with_redmine_issue')
              end
            end

            context "event JSON key 'custom_data' does NOT contain key 'redmine_issue'" do
              it "should create new Redmine issue" do
                Redmine.any_instance.should_receive(:create_issue)
                handle event_mock('without_redmine_issue')
              end

              it "should add issue URL to event JSON in Redis" do
                SensuRedis.any_instance.should_receive(:update_event_redmine_issue_url)
                handle event_mock('without_redmine_issue')
              end
            end

            describe "compiled XMPP message" do
              it "should contain event's Redmine issue URL"
            end
          end

          context "Redmine is not available" do
            pending "should create error message" do
              subject.errors.length.should eq(1)
            end
            it "should send XMPP message without issue"
            it "should send SMS"
          end



          describe "compiled XMPP message" do
            subject do
              handle(event_mock('without_redmine_issue')).xmpp_message
            end
            it "should containg priority class" do
              should include("Immediate")
            end

            it "should set priority class based on event severity (Critical > Immediate, Warning > Normal)"

            it "should contain Redmine project" do
              should include("mng-magiclab")
            end

            it "should contain Sensu check output" do
              should include("HTTP CRITICAL")
            end

            it "should contain affected host" do
              should include("node1.domain.tld")
            end

            it "should contain Sensu check name" do
              should include("frontend_http_check")
            end
          end
        end
      end

      context "jabber contact is conference" do
        it "should send xmpp message" do
          Xmpp.any_instance.should_receive(:send_message)
          handle event_mock('without_redmine_issue')
        end
      end

      context "XMPP message sending failed" do
        it "should send SMS message"
      end
    end
    
    it "should be able to handle HTTPS protocol in all Rest services"
  end
end