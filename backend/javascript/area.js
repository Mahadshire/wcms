loadArea()
btnAction = "Insert";

$(document).ready(function () {
    $("#areaForm").on("submit", function (event) {

  event.preventDefault();


  let district = $("#district").val();
  let city = $("#city").val();
  let zone = $("#zone").val();
  let update_id = $("#update_id").val();

  let sendingData = {}

  if (btnAction == "Insert") {
    sendingData = {
      "name": district,
      "city": city,
      "zone": zone,
      "action": "register_area"
    }

  } 
  else {
    sendingData = {
      "update_id": update_id,
      "name": district,
      "city": city,
      "zone": zone,
      "action": "update_Area"
    }
  }



  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/area.php",
    data: sendingData,
    success: function (data) {
      let status = data.status;
      let response = data.data;

      if (status) {
        swal("Good job!", response, "success");
        btnAction = "Insert";
        $("#areaForm")[0].reset();
        $("#areaModal").modal("show");
        loadArea();





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

function loadArea() {

  $("#areaTable thead").html('');
  $("#areaTable tbody").html('');

  let sendingData = {
    action: "read_area"
  };

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/area.php",
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

              if (res[r] === "completed") statusClass = "badge bg-success";
              else if (res[r] === "in_progress") statusClass = "badge bg-warning text-dark";
              else if (res[r] === "scheduled") statusClass = "badge bg-danger";

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

        $("#areaTable thead").append(th);
        $("#areaTable tbody").append(tr);
      }
    },

    error: function () {
      console.error("Failed to load data");
    }
  });
}


function getAreaInfo(update_id) {
  let sendingData = {
    "action": "get_Area_info",
    "update_id": update_id
  }
  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/area.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;
      if (status) {

        btnAction = "update";

        $("#update_id").val(response['id']);
        $("#district").val(response['name']);
        $("#city").val(response['city']);
        $("#zone").val(response['zone']);
        $("#areaModal").modal("show");
      } else {
        alert("error")
        // dispalaymessage("error", response);
      }

    },
    error: function (data) {
      console.log(data);
    }

  })
}


function deleteArea(id) {

  let sendingData = {
    "action": "delete_area",
    "delete_id": id
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/area.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;


      if (status) {

        swal("Good job!", response, "success");
        loadArea();


      } else {
        swal("Error", response, "error");
      }

    },
    error: function (data) {

    }

  })
}


$("#areaTable").on('click', "a.update_info", function () {
  let id = $(this).attr("update_id");
  getAreaInfo(id)
})


$("#areaTable").on('click', "a.delete_info", function () {
  let id = $(this).attr("delete_id");
  if (confirm("Are you sure To Delete")) {
    deleteArea(id)

  }

})
