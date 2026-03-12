// loadbins()
// fillAreaRequestDropdown();
// fillAllBins();
btnAction = "Insert";

$("#waste_type").on("change", function () {

  let type = $(this).val();

  if (type === "bin") {
    $("#binGroup").show();
    $("#addressGroup").hide();
    $("#address").val("");

    // load bins if area already selected
    let areaId = $("#district").val();
    if (areaId) {
      fillAllBins(areaId);
    }

  } else if (type === "house_hold") {
    $("#addressGroup").show();
    $("#binGroup").hide();
    $("#bin").html('<option disabled selected value="">Select Bin</option>');
  }

});

$(document).ready(function() {
  fillAreaRequestDropdown();  // fill options first

  $("#district").on("change", function () {
    let areaId = $(this).val();
    let areaName = $("#district option:selected").text();
    console.log("Selected Area Name:", areaName);
    let wasteType = $("#waste_type").val();

    if (wasteType === "bin") {
      fillAllBins(areaName);
    }
  });
});


// $(document.ready(function(){
//   $("#district").on("change", function ()  {
//     let areaId = $(this).val();
//     // let areaName = $("#district option:selected").text();
//     let areaName = $("#district option:selected").text();
  
//    console.log(areaName)
//     let wasteType = $("#waste_type").val();
  
//     if (wasteType === "bin") {
//       fillAllBins(areaId);
//     }
//   })
// }))

function fillAreaRequestDropdown() {

  let sendingData = {
    "action": "fill_area_request"
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "backend/Api/request.php",
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

        $("#district").append(html);


      } else {
        displaymessage("error", response);
      }

    },
    error: function (data) {

    }

  })
}
function fillAllBins(areaName) {
   $("#bin").html('<option disabled selected value="">Select Bin</option>');

  let sendingData = {
    "action": "fill_bins_dropdown",
    "areaName": areaName
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "backend/Api/request.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;
      let html = '';
      let tr = '';

      if (status) {
        response.forEach(res => {
          html += `<option value="${res.id}">${res.bin_code}</option>`;

        })

        $("#bin").append(html);


      } else {
        displaymessage("error", response);
      }

    },
    error: function (data) {

    }

  })
}

$(document).ready(function () {
    $("#requestForm").on("submit", function (event) {
    event.preventDefault();

    let wasteType = $("#waste_type").val();
    let areaId    = $("#district").val();
    let binId     = $("#bin").val();
    let address   = $("#address").val();
    let fullname   = $("#fullname").val();
    let number   = $("#number").val();

  let sendingData = {}

  if (btnAction == "Insert") {
    sendingData = {
      "wasteType": wasteType,
      "areaId": areaId,
      "binId": binId,
      "address": address,
      "fullname": fullname,
      "number": number,
      "action": "register_waste_request"
    }
    console.log(sendingData)
  } 
  else {
    sendingData = {
      "update_id": update_id,
      "name": name,
      "level": gradeLavel,
      "action": "update_grade"
    }
  }

  console.log(sendingData)


  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "backend/Api/request.php",
    data: sendingData,
    success: function (data) {
      let status = data.status;
      let response = data.data;

      if (status) {
        swal("Good job!", response, "success");
        btnAction = "Insert";
        $("#requestForm")[0].reset();
        // $("#binModal").modal("show");
        // loadbins();





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

function loadbins() {

  $("#binTable thead").html('');
  $("#binTable tbody").html('');

  let sendingData = {
    action: "read_Bins"
  };

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/bins.php",
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

              if (res[r] === "empty") statusClass = "badge bg-success";
              else if (res[r] === "half") statusClass = "badge bg-warning text-dark";
              else if (res[r] === "full") statusClass = "badge bg-danger";
              else if (res[r] === "damaged") statusClass = "badge bg-secondary";

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

        $("#binTable thead").append(th);
        $("#binTable tbody").append(tr);
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
//         loadbins();


//       } else {
//         swal(response);
//       }

//     },
//     error: function (data) {

//     }

//   })
// }

// $("#binTable").on('click', "a.update_info", function () {
//   let id = $(this).attr("update_id");
//   get_grade_info(id)
// })


// $("#binTable").on('click', "a.delete_info", function () {
//   let id = $(this).attr("delete_id");
//   if (confirm("Are you sure To Delete")) {
//     delete_grade(id)

//   }

// })
