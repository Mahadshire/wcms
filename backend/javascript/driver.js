let currentScheduleId = null;
let currentHouseHoldScheduleId = null;
// 🔒 Hide buttons on initial page load
$("#startScheduleBtn, #completeScheduleBtn").hide();
$("#House_holdStartScheduleBtn, #House_holdCompleteScheduleBtn").hide();

$(document).ready(function () {

  fillSchedules();
  fillHouseHoldSchedules();

  /* ===============================
     BUTTON RENDER FUNCTION
  =============================== */
  function renderScheduleButtons(status) {
    $("#startScheduleBtn, #completeScheduleBtn")
      .hide()
      .prop("disabled", false);

    switch (status) {
      case "scheduled":
        $("#startScheduleBtn")
          .show()
          .text("Start Schedule");
        break;

      case "in_progress":
        $("#completeScheduleBtn")
          .show()
          .text("Complete Schedule");
        break;

      case "completed":
        $("#startScheduleBtn")
          .show()
          .text("Completed")
          .prop("disabled", true);
        break;
    }
  }
  
  /* ===============================
     BUTTON RENDER FUNCTION
  =============================== */
  function renderHouseHoldScheduleButtons(status) {
    $("#House_holdStartScheduleBtn, #House_holdCompleteScheduleBtn")
      .hide()
      .prop("disabled", false);

    switch (status) {
      case "scheduled":
        $("#House_holdStartScheduleBtn")
          .show()
          .text("Start Schedule");
        break;

      case "in_progress":
        $("#House_holdCompleteScheduleBtn")
          .show()
          .text("Complete Schedule");
        break;

      case "completed":
        $("#House_holdStartScheduleBtn")
          .show()
          .text("Completed")
          .prop("disabled", true);
        break;
    }
  }

  /* ===============================
     SCHEDULE SELECTION
  =============================== */
  $("#scheduleSelect").on("change", function () {
    const schedule_id = $(this).val();
    if (!schedule_id) return;

    currentScheduleId = schedule_id;

    const status = $("#scheduleSelect option:selected").data("status");

    renderScheduleButtons(status);
    loadFullBinsTable(schedule_id);
  });

  /* ===============================
     HOUSE HOLD SCHEDULE SELECTION
  =============================== */
  $("#House_holdScheduleSelect").on("change", function () {
    console.log("changed");
    const scheduleId = $(this).val();
    if (!scheduleId) return;

    currentHouseHoldScheduleId = scheduleId;

    const status = $("#House_holdScheduleSelect option:selected").data("status");

    renderHouseHoldScheduleButtons(status);
    loadHouseHoldTable(scheduleId);
  });

  /* ===============================
     START SCHEDULE
  =============================== */
  $("#startScheduleBtn").on("click", function () {
    if (!currentScheduleId) {
      alert("Please select a schedule first");
      return;
    }

    const $btn = $(this);
    $btn.prop("disabled", true).text("Starting...");

    $.ajax({
      url: "../Api/driver.php",
      method: "POST",
      dataType: "JSON",
      data: {
        action: "start_collection_schedule",
        schedule_id: currentScheduleId
      },
      success: function (res) {
        if (!res.status) {
          alert(res.data);
          $btn.prop("disabled", false).text("Start Schedule");
          return;
        }

        alert(res.data);

        // 🔥 SYNC STATUS WITH UI
        $("#scheduleSelect option:selected")
          .data("status", "in_progress");

        renderScheduleButtons("in_progress");
        loadFullBinsTable(currentScheduleId);
      },
      error: function () {
        alert("Server error. Try again.");
        $btn.prop("disabled", false).text("Start Schedule");
      }
    });
  });

  /* ===============================
     START SCHEDULE
  =============================== */
  $("#House_holdStartScheduleBtn").on("click", function () {
    if (!currentHouseHoldScheduleId) {
      alert("Please select a schedule first");
      return;
    }

    const $btn = $(this);
    $btn.prop("disabled", true).text("Starting...");

    $.ajax({
      url: "../Api/driver.php",
      method: "POST",
      dataType: "JSON",
      data: {
        action: "start_collection_schedule",
        schedule_id: currentHouseHoldScheduleId
      },
      success: function (res) {
        if (!res.status) {
          alert(res.data);
          $btn.prop("disabled", false).text("Start Schedule");
          return;
        }

        alert(res.data);

        // 🔥 SYNC STATUS WITH UI
        $("#House_holdScheduleSelect option:selected")
          .data("status", "in_progress");

        renderHouseHoldScheduleButtons("in_progress");
        loadHouseHoldTable(currentHouseHoldScheduleId);
      },
      error: function () {
        alert("Server error. Try again.");
        $btn.prop("disabled", false).text("Start Schedule");
      }
    });
  });

  /* ===============================
     COMPLETE SCHEDULE
  =============================== */
  $("#completeScheduleBtn").on("click", function () {
    if (!currentScheduleId) return;

    $.ajax({
      url: "../Api/driver.php",
      method: "POST",
      dataType: "JSON",
      data: {
        action: "complete_schedule",
        schedule_id: currentScheduleId
      },
      success: function (res) {
        alert(res.msg);

        if (res.status) {
          $("#scheduleSelect option:selected")
            .data("status", "completed");

          $("#FullBinsTable tbody").html(`
            <tr>
              <td colspan="5" class="text-center text-success">
                Schedule completed
              </td>
            </tr>
          `);

          // Refresh schedules (completed removed)
          fillSchedules();

          currentScheduleId = null;
          $("#scheduleSelect").val("");

          $("#startScheduleBtn, #completeScheduleBtn").hide();
        }
      }
    });
  });

  /* ===============================
     COMPLETE HOUSE HOULD SCHEDULE
  =============================== */
  $("#House_holdCompleteScheduleBtn").on("click", function () {
    if (!currentHouseHoldScheduleId) return;

    $.ajax({
      url: "../Api/driver.php",
      method: "POST",
      dataType: "JSON",
      data: {
        action: "complete_household_schedule",
        schedule_id: currentHouseHoldScheduleId
      },
      success: function (res) {
        alert(res.msg);

        if (res.status) {
          $("#scheduleSelect option:selected")
            .data("status", "completed");

          $("#FullBinsTable tbody").html(`
            <tr>
              <td colspan="5" class="text-center text-success">
                Schedule completed
              </td>
            </tr>
          `);

          // Refresh schedules (completed removed)
          fillHouseHoldSchedules();

          currentHouseHoldScheduleId = null;
          $("#House_holdScheduleSelect").val("");

          $("#House_holdStartScheduleBtn, #complete_household_schedule").hide();
        }
      }
    });
  });

  /* ===============================
     FILL SCHEDULES
  =============================== */
  function fillSchedules() {
    $("#scheduleSelect").html(
      '<option disabled selected value="">Select Schedule</option>'
    );

    $.ajax({
      url: "../Api/driver.php",
      method: "POST",
      dataType: "JSON",
      data: { action: "fill_Schedules_driver" },
      success: function (data) {
        if (!data.status) return;

        const options = data.data.map(res => `
          <option 
            value="${res.schedule_id}" 
            data-status="${res.status}">
            ${res.schedule_name}
          </option>
        `);

        $("#scheduleSelect").append(options.join(""));
      }
    });
  }

  /* ===============================
     FILL House Hold SCHEDULES
  =============================== */
  function fillHouseHoldSchedules() {
    $("#House_holdScheduleSelect").html(
      '<option disabled selected value="">Select Schedule</option>'
    );

    $.ajax({
      url: "../Api/driver.php",
      method: "POST",
      dataType: "JSON",
      data: { action: "fill_House_holds_Schedules_driver" },
      success: function (data) {
        if (!data.status) return;
        console.log(data)

        const options = data.data.map(res => `
          <option 
            value="${res.schedule_id}" 
            data-status="${res.status}">
            ${res.schedule_name}
          </option>
        `);

        $("#House_holdScheduleSelect").append(options.join(""));
      }
    });
  }

  /* ===============================
     LOAD BINS
  =============================== */
  function loadFullBinsTable(schedule_id) {
    const $thead = $("#FullBinsTable thead").empty();
    const $tbody = $("#FullBinsTable tbody").empty();

    const hiddenColumns = ["request_id", "bin_id"];

    $.ajax({
      url: "../Api/driver.php",
      method: "POST",
      dataType: "JSON",
      data: {
        action: "fill_full_bins_to_collect",
        schedule_id
      },
      success: function (res) {
        if (!res.status || !res.data.length) return;

        let th = "<tr>";
        let tr = "";

        Object.keys(res.data[0]).forEach(col => {
          if (!hiddenColumns.includes(col)) {
            th += `<th>${col.replaceAll("_", " ")}</th>`;
          }
        });
        th += "<th>Action</th></tr>";
        $thead.append(th);

        res.data.forEach(row => {
          tr += "<tr>";

          Object.keys(row).forEach(key => {
            if (hiddenColumns.includes(key)) return;

            if (key === "status") {
              tr += `<td><span class="badge bg-warning">${row[key]}</span></td>`;
            } else {
              tr += `<td>${row[key] ?? "-"}</td>`;
            }
          });

          tr += `
            <td>
              <a 
                class="btn btn-xs btn-danger update_info"
                data-request-id="${row.request_id}"
                data-bin-id="${row.bin_id}">
                Collect
              </a>
            </td>
          </tr>`;
        });

        $tbody.append(tr);
      }
    });
  }

  /* ===============================
     LOAD Hous Holds
  =============================== */
  function loadHouseHoldTable(scheduleId) {
    const $thead = $("#FullHouseHoldsTable thead").empty();
    const $tbody = $("#FullHouseHoldsTable tbody").empty();

    const hiddenColumns = [];

    $.ajax({
      url: "../Api/driver.php",
      method: "POST",
      dataType: "JSON",
      data: {
        action: "fill_all_house_hold_to_collect",
        scheduleId
      },
      success: function (res) {
        if (!res.status || !res.data.length) return;

        let th = "<tr>";
        let tr = "";

        Object.keys(res.data[0]).forEach(col => {
          if (!hiddenColumns.includes(col)) {
            th += `<th>${col.replaceAll("_", " ")}</th>`;
          }
        });
        th += "<th>Action</th></tr>";
        $thead.append(th);

        res.data.forEach(row => {
          tr += "<tr>";

          Object.keys(row).forEach(key => {
            if (hiddenColumns.includes(key)) return;

            if (key === "status") {
              tr += `<td><span class="badge bg-warning">${row[key]}</span></td>`;
            } else {
              tr += `<td>${row[key] ?? "-"}</td>`;
            }
          });

          tr += `
            <td>
              <a 
                class="btn btn-xs btn-danger update_info"
                data-request-id="${row.request_id}"
                data-request-address = "${row.address}">
                Collect
              </a>
            </td>
          </tr>`;
        });

        $tbody.append(tr);
      }
    });
  }

  /* ===============================
     COLLECT BIN
  =============================== */
  $("#FullBinsTable").on("click", ".update_info", function () {
    const requestId = $(this).data("requestId");
    const binId = $(this).data("binId");

    $.ajax({
      url: "../Api/driver.php",
      method: "POST",
      dataType: "JSON",
      data: {
        action: "sp_collect_bins",
        requestId,
        binId,
        scheduleId: currentScheduleId
      },
      success: function (res) {
        if (res.status) {
          swal("Good job!", res.data, "success");
          loadFullBinsTable(currentScheduleId);
        } else {
          swal("Oops!", res.data, "error");
        }
      }
    });
  });

  $("#FullHouseHoldsTable").on("click", ".update_info", function () {
    const requestId = $(this).data("requestId");
    const address = $(this).data("requestAddress");
    console.log(requestId);
    console.log(address);

    $.ajax({
      url: "../Api/driver.php",
      method: "POST",
      dataType: "JSON",
      data: {
        action: "collect_household_waste",
        requestId,
        scheduleId: currentHouseHoldScheduleId
      },
      success: function (res) {
        if (res.status) {
          swal("Good job!", res.data, "success");
          loadHouseHoldTable(currentHouseHoldScheduleId);
        } else {
          swal("Oops!", res.data, "error");
        }
      }
    });
  });

});