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
import "./expose-standard-libs"
import "./expose-embedded-data"
import "jquery-ujs"
import "./jquery_ujs_patches"
import "./cookies"
import "datatables"
import "./datatables-bootstrap-3"

import Turbolinks from "turbolinks"
Turbolinks.start();

import "./expose"
import "chartkick/chart.js"
import "bootstrap"
import "./bootstrap-datepicker-core"
import "./bootstrap-guards"

import LocalTime from "local-time"
LocalTime.start();

import "select2/dist/js/select2.full"

// TODO: Replace this next require or fix html->text change in 2.0.2 to handle our html
// - Originally from https://github.com/bluerail/twitter-bootstrap-rails-confirm
import "./twitter-bootstrap-rails-confirm"

import "./all_or_none"
import "./auto_submit"
import "./bins"
import "./check_uncheck_all"
import "./count_sheets"
import "./custom_guards"
import "./data-tables-init"
import "./disable_save_and_export_on_external_id_input"
import "./donations"
import "./donors"
import "./external_type_select2"
import "./guards"
import "./item_program_ratios"
import "./items"
import "./migrate_donations"
import "./orders"
import "./organization"
import "./programs"
import "./purchases"
import "./select2"
import "./select_href"
import "./survey_answers"
import "./survey_requests"
import "./surveys"
import "./table_editable"
import "./table_row_click"
import "./unique_id"
import "./users"
import "./utils"
