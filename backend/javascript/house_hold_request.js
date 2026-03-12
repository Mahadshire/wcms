loadPendHoseHoldRequests()
fillHouseHoldVehiclesDropdown()
fillHouseDriversDrpdown()

function fillHouseHoldVehiclesDropdown() {

  let sendingData = {
    "action": "fill_house_holdS"
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/house_hold_request.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;
      let html = '';
      let tr = '';

      if (status) {
        response.forEach(res => {
          html += `<option value="${res.id}">${res.vehicle_number}</option>`;

        })

        $("#houseVehicles").append(html);


      } else {
        displaymessage("error", response);
      }

    },
    error: function (data) {

    }

  })
}

function fillHouseDriversDrpdown() {

  let sendingData = {
    "action": "fill_House_drivers_drpdown"
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/house_hold_request.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;
      let html = '';
      let tr = '';

      if (status) {
        response.forEach(res => {
          html += `<option value="${res.id}">${res.driver}</option>`;

        })

        $("#houseDrivers").append(html);


      } else {
        displaymessage("error", response);
      }

    },
    error: function (data) {

    }

  })
}
function loadPendHoseHoldRequests() {

  const $tableHead = $("#house_hould_CollectionTable thead");
  const $tableBody = $("#house_hould_CollectionTable tbody");

  $tableHead.empty();
  $tableBody.empty();

  const hiddenColumns = ["area_id"];

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/house_hold_request.php",
    data: { action: "read_pending_house_hold_requests" },

    success: function (res) {

      if (!res.status || !res.data.length) return;

      const data = res.data;
      let th = "<tr>";
      let tr = "";

      /* ---------- TABLE HEAD ---------- */
      Object.keys(data[0]).forEach(col => {
        if (!hiddenColumns.includes(col)) {
          th += `<th>${col.replaceAll("_", " ")}</th>`;
        }
      });
      th += "<th>Action</th></tr>";
      $tableHead.append(th);

      /* ---------- TABLE BODY ---------- */
      data.forEach(row => {

        tr += "<tr>";

        Object.keys(row).forEach(key => {

          if (hiddenColumns.includes(key)) return;

          if (key === "status") {
            tr += `
              <td>
                <span class="badge bg-warning">
                  ${row[key]}
                </span>
              </td>`;
          } else {
            tr += `<td>${row[key] ?? "-"}</td>`;
          }
        });

        tr += `
          <td>
            <a 
              class="btn btn-xs btn-info update_info"
              data-request-id="${row.id}"
              data-area-id="${row.area_id}"
              data-address="${row.address}"
            >
              approve
            </a>
            &nbsp;
            <a 
              class="btn btn-xs btn-danger reject_info"
              data-reject-id="${row.id}"
            >
              reject
            </a>
          </td>
        </tr>`;
      });

      $tableBody.append(tr);
    },

    error: function () {
      console.error("Failed to load pending House Holds requests");
    }
  });
}

function rejectHouseRequest(rejectId) {

  let sendingData = {
    "action": "reject_House_collection_request",
    "rejectId": rejectId
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/house_hold_request.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;


      if (status) {

        swal("Good job!", response, "success");
        loadPendHoseHoldRequests();


      } else {
        swal(response);
      }

    },
    error: function (data) {

    }

  })
}


$("#house_hould_CollectionTable").on('click', "a.update_info", function () {
   let requestId = $(this).data("requestId");
   let areaId    = $(this).data("area-id");
   let address     = $(this).data("address");
  console.log(requestId)
  console.log(areaId)
  console.log(address)

   $("#approveHouseHoldModal").modal('show');

   $("#houseHoldApprovelForm").on("submit", function(event) {
    event.preventDefault();

    // let schedulesDate = $("#schedules_date").val()
     let date = $("#house_schedules_date").val();
     let drivers = $("#houseDrivers").val();
     let vehicles = $("#houseVehicles").val();

     let sendingData = {
      "requestId" : requestId,
      "vehicles" : vehicles,
      "drivers" : drivers,
      "date" : date,
      "action": "approve_Hous_hold_collection"
     }
     console.log(sendingData)

     $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/house_hold_request.php",
    data: sendingData,
    success: function (data) {
      let status = data.status;
      let response = data.data;

      if (status) {
        swal("Good job!", response, "success");
        btnAction = "Insert";
        $("#houseHoldApprovelForm")[0].reset();
        $("#approveHouseHoldModal").modal("hide");
        loadPendHoseHoldRequests()





      } else {
        swal("NOW!", response, "error");
      }

    },
    error: function (data) {
      swal("NOW!", response, "error");

    }

  })

   } )
    

  
})
$("#house_hould_CollectionTable").on('click', "a.reject_info", function () {
   let rejectId = $(this).data("rejectId");
   if (confirm("Are You Sure To Reject This Request")) {
    rejectHouseRequest(rejectId);
     console.log(rejectId);
   }

})

