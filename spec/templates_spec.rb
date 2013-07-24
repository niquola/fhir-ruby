require 'spec_helper'

describe 'Fhir::TemplateFunctions' do
  let(:graph) do
    Fhir::Graph.new.tap do |g|
      g.add([1])
      g.add([1, 2])
    end
  end

  let(:selection) { graph.selection }

  it 'should render template' do
    selection
    .template { "item: <%= node.path -%>" }
    .render
    .should == "item: 1\nitem: 1.2"
  end

  it 'should render template from file' do
    selection
    .template(path: "#{File.dirname(__FILE__)}/template.erb")
    .render
    .should == "item: 1\nitem: 1.2"
  end

  it 'should render to file' do
    tmp_folder = File.join(File.dirname(__FILE__), 'tmp/models')
    FileUtils.rm_rf(tmp_folder)

    selection
    .template { "item: <%= node.path -%>" }
    .file(tmp_folder) do |node|
      "#{node.path}.txt"
    end

    File.exists?("#{tmp_folder}/1.txt").should be_true
    File.exists?("#{tmp_folder}/1.2.txt").should be_true
    File.open("#{tmp_folder}/1.txt").readlines.first.should == 'item: 1'
    File.open("#{tmp_folder}/1.2.txt").readlines.first.should == 'item: 1.2'
  end
end
