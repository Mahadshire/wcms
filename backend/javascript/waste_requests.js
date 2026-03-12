loadPendingBinRequests()
fillVehiclesDropdown()
fillDriversDrpdown()

function fillVehiclesDropdown() {

  let sendingData = {
    "action": "fill_Vehicles_drpdown"
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/waste_requests.php",
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

        $("#vehicles").append(html);


      } else {
        displaymessage("error", response);
      }

    },
    error: function (data) {

    }

  })
}

function fillDriversDrpdown() {

  let sendingData = {
    "action": "fill_driver"
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/schedule.php",
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

        $("#drivers").append(html);


      } else {
        displaymessage("error", response);
      }

    },
    error: function (data) {

    }

  })
}
function loadPendingBinRequests() {

  const $tableHead = $("#binCollectionTable thead");
  const $tableBody = $("#binCollectionTable tbody");

  $tableHead.empty();
  $tableBody.empty();

  const hiddenColumns = ["area_id", "bin_id"];

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/waste_requests.php",
    data: { action: "read_pending_bin_requests" },

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
              data-bin-id="${row.bin_id}"
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
      console.error("Failed to load pending bin requests");
    }
  });
}

function rejectRequest(rejectId) {

  let sendingData = {
    "action": "reject_bin_collection_request",
    "rejectId": rejectId
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/waste_requests.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;


      if (status) {

        swal("Good job!", response, "success");
        loadPendingBinRequests();


      } else {
        swal(response);
      }

    },
    error: function (data) {

    }

  })
}



let requestId;
let areaId;
let binId

$("#binCollectionTable").on('click', "a.update_info", function () {
  // let id = $(this).attr("updateid");
   requestId = $(this).data("requestId");
   areaId    = $(this).data("area-id");
   binId     = $(this).data("bin-id");

   $("#approveModal").modal('show');

   $("#binApprovelForm").on("submit", function(event) {
    event.preventDefault();

    // let schedulesDate = $("#schedules_date").val()
     let date = $("#schedules_date").val();
     let drivers = $("#drivers").val();
     let vehicles = $("#vehicles").val();

     let sendingData = {
      "requestId" : requestId,
      "vehicles" : vehicles,
      "drivers" : drivers,
      "date" : date,
      "action": "approve_bin_collection"
     }

     $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/waste_requests.php",
    data: sendingData,
    success: function (data) {
      let status = data.status;
      let response = data.data;

      if (status) {
        swal("Good job!", response, "success");
        btnAction = "Insert";
        $("#binApprovelForm")[0].reset();
        $("#approveModal").modal("show");
        loadPendingBinRequests()





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


$("#binCollectionTable").on('click', "a.reject_info", function () {
  // let id = $(this).attr("delete_id");
  let rejectId = $(this).data("rejectId");
  if (confirm("Are you sure To Reject This Request")) {
    rejectRequest(rejectId)
    console.log(rejectId);

  }

})
