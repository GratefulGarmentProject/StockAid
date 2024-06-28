/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const removeOrgRows = $table => $table.find("tbody tr.additional-organization-row").remove();

const rezebra = function($table) {
  $table.find("tbody tr:visible:even").removeClass("odd-row even-row").addClass("odd-row");
  return $table.find("tbody tr:visible:odd").removeClass("odd-row even-row").addClass("even-row");
};

const addOrgRows = $table => $table.find("tbody tr:visible[data-has-additional-organizations]").each(function() {
  let rowClass;
  const $row = $(this);
  let $rows = $();

  if ($row.is(".odd-row")) {
    rowClass = "odd-row";
  } else {
    rowClass = "even-row";
  }

  for (var organization of Array.from($row.data("additionalOrganizations"))) {
    var row = tmpl("users-additional-organization-row-template", {
      rowClass,
      organization
    }
    );
    var $newRow = $(row);
    $rows = $rows.add($newRow);
  }

  return $row.after($rows);
});

$(document).on("draw.dt search.dt order.dt", ".users-table.data-table", function() {
  const $table = $(this);
  removeOrgRows($table);
  rezebra($table);
  return addOrgRows($table);
});
