// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require bootstrap-sprockets
//= require accounting
//= require_tree .

$(document).on('turbolinks:load', function() {
  const $cost = $('.js-membership-purchase-form-cost');
  const $numGuests = $('.js-membership-purchase-form-num-guests');
  const $selectLevel = $('.js-membership-purchase-form-select-level');
  const $title = $('.js-membership-purchase-form-title-level');

  const allLevelData = $selectLevel.data();

  function calculateNumChargedGuests(data) {
    return Math.max(Number($numGuests.val()) - data.num_free_guests, 0);
  }

  function calculateCost(data) {
    return data.usd_cost + calculateNumChargedGuests(data) * data.additional_guest_usd_cost;
  }

  function updateCostUI() {
    const levelData = allLevelData[$selectLevel.val()];

    if (!levelData) return;

    const cost = calculateCost(levelData);
    $cost.text(accounting.formatMoney(cost / 100));
  }

  function updateLevelUI() {
    const levelData = allLevelData[$selectLevel.val()];

    if (!levelData) return;

    $title.text(levelData.name);
  }

  $numGuests.on('input', updateCostUI);
  $selectLevel.on('change', updateCostUI);
  $selectLevel.on('change', updateLevelUI);
});
