require 'spec_helper'
require 'rake'
require 'rails'

DOMAIN = CONNECTION_PARAMS[:domain_name]

def delete_domain_if_exist
  ActiveRecord::Base.establish_connection(CONNECTION_PARAMS)
  con = ActiveRecord::Base.connection
  con.delete_domain(DOMAIN) if con.list_domains.include? DOMAIN
end

def recreate_domain
  delete_domain_if_exist
  ActiveRecord::Base.connection.create_domain DOMAIN
end

describe "gem rake tasks" do
  before do
    unless defined? @rake
      Rake.application.rake_require "tasks/simpledb"
      Rake::Task.define_task(:environment)
      ActiveRecord::Base.stub!(:configurations).and_return({"development" => CONNECTION_PARAMS})
      Rails.stub!(:env).and_return("development")
      Rails.stub!(:logger).and_return(Logger.new(STDOUT))
      Rails.stub!(:root).and_return(File.dirname(__FILE__) + "/../assets")
      @rake = Rake.application
    end
  end
  
  after do
    delete_domain_if_exist
  end

  describe "db:create" do
    before do
      @task_name = "db:create"
      delete_domain_if_exist
    end
    it "should create sdb domain" do
      @rake[@task_name].invoke
      ActiveRecord::Base.connection.list_domains.should include(DOMAIN)
    end
  end

  describe "db:drop" do
    before do
      @task_name = "db:drop"
      recreate_domain
    end
    it "should drop sdb domain" do
      @rake[@task_name].invoke
      ActiveRecord::Base.connection.list_domains.should_not include(DOMAIN)
    end
  end

  describe "db:seed" do
    before do
      @task_name = "db:seed"
      recreate_domain
    end
    it "should pushing data to sdb domain" do
      @rake[@task_name].invoke
      Person.count.should == 1
    end
  end
  
  describe "db:collection:clear" do
    before do
      @task_name = "db:collection:clear"
      recreate_domain
      Person.create!(Person.valid_params)
    end

    it "should receive param with name \"name\"" do
      @rake[@task_name].arg_names.should include(:name)
    end

    it "should clear collection by name" do
      @rake[@task_name].invoke("person")
      Person.count.should == 0
    end
  end

  describe "db:export" do
    before do
      @dump_file = File.join(Rails.root, 'db', 'seeds.yml')
      @task_name = "db:export"
      recreate_domain
      @person = Person.create!(Person.valid_params)
    end

    after do
      File.delete(@dump_file) if File.exist? @dump_file
    end

    it "should receive param with name \"collections\"" do
      @rake[@task_name].arg_names.should include(:collections)
    end

    it "should export collections to yaml file" do
      @rake[@task_name].invoke("person")
      data = YAML.load_file(@dump_file)
      data["person"].each do |key, value|
        @person.attributes[key].should == value
      end
    end
  end

  describe "db:import" do
    before do
      @dump_file = File.join(Rails.root, 'db', 'seeds.yml')
      @task_name = "db:import"
      recreate_domain
      @person = Person.create!(Person.valid_params)
      @rake["db:export"].reenable
      @rake["db:export"].invoke("person")
      recreate_domain
    end

    after do
      File.delete(@dump_file) if File.exist? @dump_file
    end

    it "should import collections from yaml file" do
      @rake[@task_name].invoke
      p = Person.first
      Person.count.should == 1
      Person.valid_params.each do |key, value|
        p.try(key).should == value
      end
    end
  end
end
