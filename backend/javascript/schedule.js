loadSchedules()
fillArea();
fillDriver();
fillVehicles();
btnAction = "Insert";


function fillVehicles() {

  let sendingData = {
    "action": "fill_Vehicles"
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
          html += `<option value="${res.id}">${res.vehicle_number}</option>`;

        })

        $("#vehicle").append(html);


      } else {
        displaymessage("error", response);
      }

    },
    error: function (data) {

    }

  })
}
function fillArea() {

  let sendingData = {
    "action": "fill_schedule_area"
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
          html += `<option value="${res.id}">${res.name}</option>`;

        })

        $("#schedule_area").append(html);


      } else {
        displaymessage("error", response);
      }

    },
    error: function (data) {

    }

  })
}
function fillDriver() {

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

        $("#driver").append(html);


      } else {
        displaymessage("error", response);
      }

    },
    error: function (data) {

    }

  })
}

$(document).ready(function () {
    $("#scheduleForm").on("submit", function (event) {

  event.preventDefault();


  let schedule_area = $("#schedule_area").val();
  let vehicle = $("#vehicle").val();
  let driver = $("#driver").val();
  let schedule_date = $("#schedule_date").val();
//   let update_id = $("#update_id").val();

  let sendingData = {}

  if (btnAction == "Insert") {
    sendingData = {
      "schedule_area": schedule_area,
      "vehicle": vehicle,
      "driver": driver,
      "schedule_date": schedule_date,
      "action": "register_schedules"
    }

  } 
  else {
    sendingData = {
      "update_id": update_id,
      "name": name,
      "level": gradeLavel,
      "action": "update_grade"
    }
  }



  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/schedule.php",
    data: sendingData,
    success: function (data) {
      let status = data.status;
      let response = data.data;

      if (status) {
        swal("Good job!", response, "success");
        btnAction = "Insert";
        $("#scheduleForm")[0].reset();
        $("#scheduleModal").modal("show");
        loadSchedules();





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

function loadSchedules() {

  $("#scheduleTable thead").html('');
  $("#scheduleTable tbody").html('');

  let sendingData = {
    action: "read_schedules"
  };

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/schedule.php",
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

        // ===== Table Body =====
        response.forEach(res => {

          tr += "<tr>";

          for (let r in res) {

            // ===== Status coloring =====
            if (r === "status") {

              let statusClass = "";

              if (res[r] === "completed") statusClass = "badge bg-success";
              else if (res[r] === "in_progress") statusClass = "badge bg-warning text-dark";
              else if (res[r] === "scheduled") statusClass = "badge bg-danger";

              tr += `<td><span class="${statusClass}">${res[r]}</span></td>`;

            } else {

              tr += `<td>${res[r]}</td>`;

            }
          }

          // ===== Action Buttons =====
          
        });

        $("#scheduleTable thead").append(th);
        $("#scheduleTable tbody").append(tr);
      }
    },

    error: function () {
      console.error("Failed to load data");
    }
  });
}




// function get_grade_info(update_id) {

//   let sendingData = {
//     "action": "get_grade_info",
//     "update_id": update_id
//   }

//   $.ajax({
//     method: "POST",
//     dataType: "JSON",
//     url: "Api/grade.php",
//     data: sendingData,

//     success: function (data) {
//       let status = data.status;
//       let response = data.data;


//       if (status) {

//         btnAction = "update";

//         $("#update_id").val(response['id']);
//         $("#name").val(response['name']);
//         $("#gradeLavel").val(response['level_id']);
    
//         $("#gradeModal").modal('show');




//       } else {
//         dispalaymessage("error", response);
//       }

//     },
//     error: function (data) {

//     }

//   })
// }


// function delete_grade(id) {

//   let sendingData = {
//     "action": "delete_grade",
//     "delete_id": id
//   }

//   $.ajax({
//     method: "POST",
//     dataType: "JSON",
//     url: "Api/grade.php",
//     data: sendingData,

//     success: function (data) {
//       let status = data.status;
//       let response = data.data;


//       if (status) {

//         swal("Good job!", response, "success");
//         loadSchedules();


//       } else {
//         swal(response);
//       }

//     },
//     error: function (data) {

//     }

//   })
// }

$("#scheduleTable").on('click', "a.update_info", function () {
  let id = $(this).attr("update_id");
  get_grade_info(id)
})


$("#scheduleTable").on('click', "a.delete_info", function () {
  let id = $(this).attr("delete_id");
  if (confirm("Are you sure To Delete")) {
    delete_grade(id)

  }

})
