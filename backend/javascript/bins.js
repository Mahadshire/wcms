loadbins()
fillArea();
btnAction = "Insert";


function fillArea() {

  let sendingData = {
    "action": "fill_areas_dropdown"
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/bins.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;
      let html = '';
      let tr = '';

      if (status) {
        response.forEach(res => {
          html += `<option value="${res.id}">${res.area}</option>`;

        })

        $("#area").append(html);


      } else {
        displaymessage("error", response);
      }

    },
    error: function (data) {

    }

  })
}

$(document).ready(function () {
    $("#binForm").on("submit", function (event) {

  event.preventDefault();


  let code = $("#bin_code").val();
  let capacity = $("#capacity").val();
  let area = $("#area").val();
  let update_id = $("#update_id").val();

  let sendingData = {}

  if (btnAction == "Insert") {
    sendingData = {
      "code": code,
      "area": area,
      "capacity": capacity,
      "action": "register_bin"
    }

  } 
  else {
    sendingData = {
      "update_id": update_id,
      "code": code,
      "area": area,
      "capacity": capacity,
      "action": "update_bins"
    }
  }



  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/bins.php",
    data: sendingData,
    success: function (data) {
      let status = data.status;
      let response = data.data;

      if (status) {
        swal("Good job!", response, "success");
        btnAction = "Insert";
        $("#binForm")[0].reset();
        $("#binModal").modal("hide");
        loadbins();





      } else {
        swal("Error!", response, "error");
      }

    },
    error: function (data) {
      swal("Error!", "Something went wrong", "error");

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


function getBinsInfo(update_id) {
  let sendingData = {
    "action": "get_bins_info",
    "update_id": update_id
  }
  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/bins.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;
      if (status) {

        btnAction = "update";

        $("#update_id").val(response['id']);
        $("#bin_code").val(response['bin_code']);
        $("#capacity").val(response['capacity_kg']);
        $("#area").val(response['area_id']);
        $("#binModal").modal("show");
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


function deleteBins(id) {

  let sendingData = {
    "action": "delete_bins",
    "delete_id": id
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/bins.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;


      if (status) {

        swal("Good job!", response, "success");
        loadbins();


      } else {
        swal("Error", response, "error");
      }

    },
    error: function (data) {
      swal("Error!", "Something went wrong", "error");
    }

  })
}




$("#binTable").on('click', "a.update_info", function () {
  let id = $(this).attr("update_id");
  getBinsInfo(id)
})


$("#binTable").on('click', "a.delete_info", function () {
  let id = $(this).attr("delete_id");
  if (confirm("Are you sure To Delete")) {
    deleteBins(id)

  }

})
