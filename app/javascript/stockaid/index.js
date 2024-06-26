// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
require("jquery")
require("jquery-ujs")
require("./jquery_ujs_patches")
require("./cookies")
require("datatables")
require("./datatables-bootstrap-3")
var Turbolinks = require("turbolinks")
Turbolinks.start();
require("./expose")
require("chartkick/chart.js")
require("bootstrap")
require("./bootstrap-datepicker-core")
require("./bootstrap-guards")
var LocalTime = require("local-time")
LocalTime.start();
require("select2/dist/js/select2.full")
// TODO: Replace this next require or fix html->text change in 2.0.2 to handle our html
// - Originally from https://github.com/bluerail/twitter-bootstrap-rails-confirm
require("./twitter-bootstrap-rails-confirm")

require("./all_or_none")
require("./auto_submit")
require("./bins")
require("./check_uncheck_all")
require("./count_sheets")
require("./custom_guards")
require("./data-tables-init")
require("./donations")
require("./external_type_select2")
require("./guards")
require("./item_program_ratios")
require("./items")
require("./migrate_donations")
require("./orders")
require("./organization")
require("./programs")
require("./purchases")
require("./select2")
require("./select_href")
require("./survey_answers")
require("./survey_requests")
require("./surveys")
require("./table_editable")
require("./table_row_click")
require("./unique_id")
require("./users")
require("./utils")
require("./vendors")
