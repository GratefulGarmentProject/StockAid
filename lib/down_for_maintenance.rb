# frozen_string_literal: true

# This is a Rack middleware for presenting a down for maintenance page. It can
# be enabled via setting the STOCKAID_DOWN_FOR_MAINTENANCE environment variable
# to a value, or by touching the tmp/down_for_maintenance.txt file.
#
# If you want to customize the message, you can use environment variables or the
# above file. For environment variables, you can use:
# * STOCKAID_DOWN_FOR_MAINTENANCE_TITLE
# * STOCKAID_DOWN_FOR_MAINTENANCE_MESSAGE
# * STOCKAID_DOWN_FOR_MAINTENANCE_SUBMESSAGE
#
# You could also use the context of the file. If only 1 line is provided, it
# will override the message. If 2 lines are provided, the first will be the
# title, and the second will be the message. If 3 lines are provided, the first
# will be the title, the second is the message, and the third will be the
# submessage.
#
# For customized messages, the file will first be considered, then the
# environment.
class DownForMaintenance
  FILE_PATH = "tmp/down_for_maintenance.txt".freeze
  DOWN_FOR_MAINTENANCE_STATUS = 503
  DEFAULT_TITLE = "Down for Maintenance".freeze
  DEFAULT_MESSAGE = "The site is currently down for maintenance and will be back up as soon as possible".freeze
  DEFAULT_SUBMESSAGE = "".freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    if enabled?
      read_file
      [DOWN_FOR_MAINTENANCE_STATUS, headers, [html]]
    else
      @app.call(env)
    end
  end

  def down_for_maintenance_file
    @down_for_maintenance_file ||= Rails.root.join(FILE_PATH)
  end

  def title
    if @file_contents.size >= 2
      @file_contents[0]
    elsif ENV["STOCKAID_DOWN_FOR_MAINTENANCE_TITLE"].present?
      ENV["STOCKAID_DOWN_FOR_MAINTENANCE_TITLE"]
    else
      DEFAULT_TITLE
    end
  end

  def message
    if @file_contents.size == 1
      @file_contents[0]
    elsif @file_contents.size >= 2
      @file_contents[1]
    elsif ENV["STOCKAID_DOWN_FOR_MAINTENANCE_MESSAGE"].present?
      ENV["STOCKAID_DOWN_FOR_MAINTENANCE_MESSAGE"]
    else
      DEFAULT_MESSAGE
    end
  end

  def submessage
    if @file_contents.size >= 3
      @file_contents[2]
    elsif ENV["STOCKAID_DOWN_FOR_MAINTENANCE_SUBMESSAGE"].present?
      ENV["STOCKAID_DOWN_FOR_MAINTENANCE_SUBMESSAGE"]
    else
      DEFAULT_SUBMESSAGE
    end
  end

  private

  def read_file
    @file_contents =
      if file_enabled?
        down_for_maintenance_file.readlines.map(&:strip)
      else
        []
      end
  end

  def enabled?
    env_enabled? || file_enabled?
  end

  def env_enabled?
    ENV["STOCKAID_DOWN_FOR_MAINTENANCE"].present?
  end

  def file_enabled?
    down_for_maintenance_file.exist?
  end

  def headers
    {
      "Cache-Control" => "max-age=0, private, must-revalidate",
      "Content-Type" => "text/html"
    }
  end

  def html # rubocop:disable Metrics/MethodLength
    title_html = ERB::Util.html_escape(title)
    message_html = %(<p class="message">#{ERB::Util.html_escape(message)}</p>)
    submessage_html = submessage

    if submessage_html.present?
      submessage_html = %(<p class="submessage">#{ERB::Util.html_escape(submessage_html)}</p>)
    else
      submessage_html = message_html
      message_html = ""
    end

    %(<!DOCTYPE html>
<html>
  <head>
    <title>#{title_html}</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <style>
      body {
        background-color: #EFEFEF;
        color: #2E2F30;
        text-align: center;
        font-family: arial, sans-serif;
        margin: 0;
      }

      div.dialog {
        width: 95%;
        max-width: 33em;
        margin: 4em auto 0;
      }

      div.dialog > div {
        border: 1px solid #CCC;
        border-right-color: #999;
        border-left-color: #999;
        border-bottom-color: #BBB;
        border-top: #B00100 solid 4px;
        border-top-left-radius: 9px;
        border-top-right-radius: 9px;
        background-color: white;
        padding: 7px 12% 0;
        box-shadow: 0 3px 8px rgba(50, 50, 50, 0.17);
      }

      h1 {
        font-size: 100%;
        color: #730E15;
        line-height: 1.5em;
      }

      div.dialog > p {
        margin: 0 0 1em;
        padding: 1em;
        background-color: #F7F7F7;
        border: 1px solid #CCC;
        border-right-color: #999;
        border-left-color: #999;
        border-bottom-color: #999;
        border-bottom-left-radius: 4px;
        border-bottom-right-radius: 4px;
        border-top-color: #DADADA;
        color: #666;
        box-shadow: 0 3px 8px rgba(50, 50, 50, 0.17);
      }
    </style>
  </head>

  <body>
    <div class="dialog">
      <div>
        <h1>#{title_html}</h1>
        #{message_html}
      </div>

      #{submessage_html}
    </div>
  </body>
</html>
)
  end
end
