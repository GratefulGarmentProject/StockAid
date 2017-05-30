require "rails_helper"

describe DownForMaintenance do
  let(:fake_app) do
    lambda do |_env|
      @called = true
      :lambda_result
    end
  end

  let(:middleware) { DownForMaintenance.new(fake_app) }

  context "not enabled" do
    it "invokes the app" do
      result = middleware.call({})
      expect(result).to eq(:lambda_result)
      expect(@called).to be_truthy
    end
  end

  context "enabled via environment" do
    it "can just enable the maintenance" do
      with_env STOCKAID_DOWN_FOR_MAINTENANCE: "true" do
        result = middleware.call({})
        expect(@called).to be_falsey
        expect(result[2].first).to match(%r{<title>#{DownForMaintenance::DEFAULT_TITLE}</title>})
        expect(result[2].first).to match(%r{<h1>#{DownForMaintenance::DEFAULT_TITLE}</h1>})
        expect(result[2].first).to match(%r{<p class="message">#{DownForMaintenance::DEFAULT_MESSAGE}</p>})
        expect(result[2].first).to_not match(/<p class="submessage">/)
      end
    end

    it "can override the page details" do
      with_env STOCKAID_DOWN_FOR_MAINTENANCE: "true",
               STOCKAID_DOWN_FOR_MAINTENANCE_TITLE: "Custom Title",
               STOCKAID_DOWN_FOR_MAINTENANCE_MESSAGE: "Custom Message",
               STOCKAID_DOWN_FOR_MAINTENANCE_SUBMESSAGE: "Custom Submessage" do
        result = middleware.call({})
        expect(@called).to be_falsey
        expect(result[2].first).to match(%r{<title>Custom Title</title>})
        expect(result[2].first).to match(%r{<h1>Custom Title</h1>})
        expect(result[2].first).to match(%r{<p class="message">Custom Message</p>})
        expect(result[2].first).to match(%r{<p class="submessage">Custom Submessage</p>})
      end
    end

    it "sanitizes the overridden details" do
      with_env STOCKAID_DOWN_FOR_MAINTENANCE: "true",
               STOCKAID_DOWN_FOR_MAINTENANCE_TITLE: "Custom <Title>",
               STOCKAID_DOWN_FOR_MAINTENANCE_MESSAGE: "Custom <Message>",
               STOCKAID_DOWN_FOR_MAINTENANCE_SUBMESSAGE: "Custom <Submessage>" do
        result = middleware.call({})
        expect(@called).to be_falsey
        expect(result[2].first).to match(%r{<title>Custom &lt;Title&gt;</title>})
        expect(result[2].first).to match(%r{<h1>Custom &lt;Title&gt;</h1>})
        expect(result[2].first).to match(%r{<p class="message">Custom &lt;Message&gt;</p>})
        expect(result[2].first).to match(%r{<p class="submessage">Custom &lt;Submessage&gt;</p>})
      end
    end
  end

  context "enabled via files" do
    include FakeFS::SpecHelpers
    let(:maintenance_file) { middleware.down_for_maintenance_file }
    before { FileUtils.mkdir_p maintenance_file.dirname }

    it "can just enable the maintenance" do
      File.write(maintenance_file, "")
      result = middleware.call({})
      expect(@called).to be_falsey
      expect(result[2].first).to match(%r{<title>#{DownForMaintenance::DEFAULT_TITLE}</title>})
      expect(result[2].first).to match(%r{<h1>#{DownForMaintenance::DEFAULT_TITLE}</h1>})
      expect(result[2].first).to match(%r{<p class="message">#{DownForMaintenance::DEFAULT_MESSAGE}</p>})
      expect(result[2].first).to_not match(/<p class="submessage">/)
    end

    it "can override just the message" do
      File.write(maintenance_file, "Custom Message\n")
      result = middleware.call({})
      expect(@called).to be_falsey
      expect(result[2].first).to match(%r{<title>#{DownForMaintenance::DEFAULT_TITLE}</title>})
      expect(result[2].first).to match(%r{<h1>#{DownForMaintenance::DEFAULT_TITLE}</h1>})
      expect(result[2].first).to match(%r{<p class="message">Custom Message</p>})
      expect(result[2].first).to_not match(/<p class="submessage">/)
    end

    it "can override just the message and title" do
      File.write(maintenance_file, "Custom Title\nCustom Message\n")
      result = middleware.call({})
      expect(@called).to be_falsey
      expect(result[2].first).to match(%r{<title>Custom Title</title>})
      expect(result[2].first).to match(%r{<h1>Custom Title</h1>})
      expect(result[2].first).to match(%r{<p class="message">Custom Message</p>})
      expect(result[2].first).to_not match(/<p class="submessage">/)
    end

    it "can override all the page details" do
      File.write(maintenance_file, "Custom Title\nCustom Message\nCustom Submessage\n")
      result = middleware.call({})
      expect(@called).to be_falsey
      expect(result[2].first).to match(%r{<title>Custom Title</title>})
      expect(result[2].first).to match(%r{<h1>Custom Title</h1>})
      expect(result[2].first).to match(%r{<p class="message">Custom Message</p>})
      expect(result[2].first).to match(%r{<p class="submessage">Custom Submessage</p>})
    end

    it "sanitizes the overridden details" do
      File.write(maintenance_file, "Custom <Title>\nCustom <Message>\nCustom <Submessage>\n")
      result = middleware.call({})
      expect(@called).to be_falsey
      expect(result[2].first).to match(%r{<title>Custom &lt;Title&gt;</title>})
      expect(result[2].first).to match(%r{<h1>Custom &lt;Title&gt;</h1>})
      expect(result[2].first).to match(%r{<p class="message">Custom &lt;Message&gt;</p>})
      expect(result[2].first).to match(%r{<p class="submessage">Custom &lt;Submessage&gt;</p>})
    end
  end
end
