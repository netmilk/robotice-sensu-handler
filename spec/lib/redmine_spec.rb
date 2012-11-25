require File.join(File.dirname(__FILE__),'..','spec_helper.rb')

describe Redmine do

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

  before do
    stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld").
    to_return(:status => 200, :body => "", :headers => {})

    stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld/frontend_http_check").
    to_return(:status => 200, :body => "", :headers => {})

    Xmpp.any_instance.stub(:send_message).and_return(true)
  end
  describe "object instance" do
    subject{Redmine.new(handler)}
    it{should respond_to(:handler)}

    it "should raise if first argument is not VirtualmasterHandler" do
      lambda{
        Redmine.new('some string')
      }.should raise_error
    end

    context  "handler settings does not contain virtualmster.redmine" do
      it "should raise" do
        h = handle event_mock('without_custom_data')
        h.settings['virtualmaster'].delete('redmine')
        lambda{
          Redmine.new h
        }.should raise_error(StandardError, 'Sensu handler config have to contain "redmine" section')
      end
    end

    describe "#create_issue" do
      before do
        @f = Redmine.new(handle(event_mock('without_custom_data')))
      end
      context "Redmine is available" do
        context "and it takes more than timeout limit in config" do
          before do
            stub_request(:post, "http://redmine.domain.tld/issues.json?key=s3c43tmuchmuchlonger").
              with(:body => valid_issue.to_json,
                   :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'User-Agent'=>'Virtualmaster Sensu handler'}).
              to_timeout
          end

          it "should raise" do
            limit = settings['virtualmaster']['redmine']['timeout']
            lambda{
              subject.create_issue(valid_issue)
            }.should raise_error(StandardError, "Redmine timeouted after #{limit} seconds.")
          end
        end

        context "and project does not exist in Redmine or issue not created" do
          before do
            issue_with_non_existent_project = valid_issue
            @fake_project = issue_with_non_existent_project['issue']['project_id'] = 'wroom'
            stub_request(:post, "http://redmine.domain.tld/issues.json?key=s3c43tmuchmuchlonger").
              with(:body => issue_with_non_existent_project.to_json,
                   :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'User-Agent'=>'Virtualmaster Sensu handler'}).
              to_return(mock_response('redmine/issue-uknown-project'))
          end

          it "should return false" do
            issue = valid_issue
            issue['issue']['project_id'] = @fake_project
            subject.create_issue(issue).should eq(false)
          end
        end

        context "project exists in Redmine" do
          before do
            stub_request(:post, "http://redmine.domain.tld/issues.json?key=s3c43tmuchmuchlonger").
              with(:body => valid_issue.to_json,
                   :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'User-Agent'=>'Virtualmaster Sensu handler'}).
              to_return(mock_response('redmine/issue-success'))
          end

          it "should successfuly create issue" do
            subject.create_issue(valid_issue).should_not eq(false)
          end
          it "should return hash containing requested subject" do
            returned_issue = subject.create_issue(valid_issue)
            returned_issue['issue']['subject'].should eq(valid_issue['issue']['subject'])
          end
          
          describe "compiled XMPP message" do 
            it "should contain issue ID"
          end
        end
      end
    end
  end
end
