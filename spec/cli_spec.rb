# encoding: utf-8
require File.join(File.dirname(__FILE__), "spec_helper.rb")

describe Teamocil::CLI do

  context "executing" do

      before do # {{{
        @fake_env = { "TMUX" => 1, "HOME" => File.join(File.dirname(__FILE__), "fixtures") }
      end # }}}

    context "not in tmux" do

      it "should allow editing" do # {{{
        FileUtils.stub(:touch)
        Kernel.should_receive(:system).with(any_args())

        @cli = Teamocil::CLI.new(["--edit", "my-layout"], @fake_env)
      end # }}}

    end

    context "in tmux" do

      before :each do # {{{
        Teamocil::CLI.messages = []
      end # }}}

      it "creates a layout from a name" do # {{{
        @cli = Teamocil::CLI.new(["sample"], @fake_env)
        @cli.layout.session.name.should == "sample"
        @cli.layout.session.windows.length.should == 2
        @cli.layout.session.windows.first.name.should == "foo"
        @cli.layout.session.windows.last.name.should == "bar"
      end # }}}

      it "fails to create a layout from a layout that doesn’t exist" do # {{{
        lambda { @cli = Teamocil::CLI.new(["i-do-not-exist"], @fake_env) }.should raise_error SystemExit
        Teamocil::CLI.messages.should include("There is no file \"#{File.join(File.dirname(__FILE__), "fixtures", ".teamocil", "i-do-not-exist.yml")}\"")
      end # }}}

      it "creates a layout from a specific file" do # {{{
        @cli = Teamocil::CLI.new(["--layout", "./spec/fixtures/.teamocil/sample.yml"], @fake_env)
        @cli.layout.session.name.should == "sample"
        @cli.layout.session.windows.length.should == 2
        @cli.layout.session.windows.first.name.should == "foo"
        @cli.layout.session.windows.last.name.should == "bar"
      end # }}}

      it "fails to create a layout from a file that doesn’t exist" do # {{{
        lambda { @cli = Teamocil::CLI.new(["--layout", "./spec/fixtures/.teamocil/i-do-not-exist.yml"], @fake_env) }.should raise_error SystemExit
        Teamocil::CLI.messages.should include("There is no file \"./spec/fixtures/.teamocil/i-do-not-exist.yml\"")
      end # }}}

      it "lists available layouts" do # {{{
        @cli = Teamocil::CLI.new(["--list"], @fake_env)
        @cli.layouts.should == ["sample", "sample-2"]
      end # }}}

    end

  end
end
