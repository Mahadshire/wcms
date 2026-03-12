loadVehicles()
// fillArea();
btnAction = "Insert";


// function fillArea() {

//   let sendingData = {
//     "action": "fill_areas_dropdown"
//   }

//   $.ajax({
//     method: "POST",
//     dataType: "JSON",
//     url: "../Api/vehicles.php",
//     data: sendingData,

//     success: function (data) {
//       let status = data.status;
//       let response = data.data;
//       let html = '';
//       let tr = '';

//       if (status) {
//         response.forEach(res => {
//           html += `<option value="${res.id}">${res.name}</option>`;

//         })

//         $("#area").append(html);


//       } else {
//         displaymessage("error", response);
//       }

//     },
//     error: function (data) {

//     }

//   })
// }

$(document).ready(function () {
    $("#vehiclesForm").on("submit", function (event) {

  event.preventDefault();


  let vehicle_number = $("#vehicle_number").val();
  let capacity = $("#capacity").val();
  let update_id = $("#update_id").val();

  let sendingData = {}

  if (btnAction == "Insert") {
    sendingData = {
      "vehicle_number": vehicle_number,
      "capacity": capacity,
      "action": "register_vehicles"
    }

  } 
  else {
    sendingData = {
      "update_id": update_id,
      "vehicle": vehicle_number,
      "capacity": capacity,
      "action": "update_vehicles"
    }
  }



  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/vehicles.php",
    data: sendingData,
    success: function (data) {
      let status = data.status;
      let response = data.data;

      if (status) {
        swal("Good job!", response, "success");
        btnAction = "Insert";
        $("#vehiclesForm")[0].reset();
        $("#vehiclesModal").modal("hide");
        loadVehicles();





      } else {
        swal("NOW!", response, "error");
      }

    },
    error: function (data) {
      swal("NOW!", response, "error");

    }

  })

})

});

function loadVehicles() {

  $("#vehiclesTable thead").html('');
  $("#vehiclesTable tbody").html('');

  let sendingData = {
    action: "read_vehicles"
  };

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/vehicles.php",
    data: sendingData,

    success: function (data) {

      let status = data.status;
      let response = data.data;
      let th = '';
      let tr = '';

      if (status) {

        // ===== Table Head (once) =====
        th += "<tr>";
        for (let key in response[0]) {
          th += `<th>${key}</th>`;
        }
        th += "<th>Action</th></tr>";

        // ===== Table Body =====
        response.forEach(res => {

          tr += "<tr>";

          for (let r in res) {

            // ===== Status coloring =====
            if (r === "status") {

              let statusClass = "";

              if (res[r] === "available") statusClass = "badge bg-success";
              else if (res[r] === "on_route") statusClass = "badge bg-warning text-dark";
              else if (res[r] === "maintenance") statusClass = "badge bg-danger";

              tr += `<td><span class="${statusClass}">${res[r]}</span></td>`;

            } else {

              tr += `<td>${res[r]}</td>`;

            }
          }

          // ===== Action Buttons =====
          tr += `
            <td>
              <a class="btn btn-info update_info" update_id="${res.id}">
                <i class="fas fa-edit" style="color:#fff"></i>
              </a>
              &nbsp;
              <a class="btn btn-danger delete_info" delete_id="${res.id}">
                <i class="fas fa-trash" style="color:#fff"></i>
              </a>
            </td>
          `;

          tr += "</tr>";
        });

        $("#vehiclesTable thead").append(th);
        $("#vehiclesTable tbody").append(tr);
      }
    },

    error: function () {
      console.error("Failed to load data");
    }
  });
}

function getVehicleInfo(update_id) {
  let sendingData = {
    "action": "get_vehicle_info",
    "update_id": update_id
  }
  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/vehicles.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;
      if (status) {

        btnAction = "update";

        $("#update_id").val(response['id']);
        $("#vehicle_number").val(response['vehicle_number']);
        $("#capacity").val(response['capacity_kg']);
        $("#vehiclesModal").modal("show");
      } else {
        swal("Error", response, "error");

      }

    },
    error: function (data) {
      swal("Error!", "Something went wrong", "error");

    }

  })
}

function deleteVehicles(id) {

  let sendingData = {
    "action": "delete_vehicles",
    "delete_id": id
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/vehicles.php",
    data: sendingData,

    success: function (data) {
      console.log(data)
      let status = data.status;
      let response = data.data;

      if (status) {

        swal("Good job!", response, "success");
        loadVehicles();


      } else {
        swal("Error", response, "error");
      }

    },
    error: function (data) {
      swal("Error!", "Something went wrong", "error");
    }

  })
}


$("#vehiclesTable").on('click', "a.update_info", function () {
  let id = $(this).attr("update_id");
  getVehicleInfo(id)
})


$("#vehiclesTable").on('click', "a.delete_info", function () {
  let id = $(this).attr("delete_id");
  if (confirm("Are you sure To Delete")) {
    deleteVehicles(id)

  }

})
