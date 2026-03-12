loadRoles()
// fillLevels();
btnAction = "Insert";

// function fillLevels() {

//   let sendingData = {
//     "action": "fillLevels"
//   }

//   $.ajax({
//     method: "POST",
//     dataType: "JSON",
//     url: "Api/grade.php",
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

//         $("#gradeLavel").append(html);


//       } else {
//         displaymessage("error", response);
//       }

//     },
//     error: function (data) {

//     }

//   })
// }

$(document).ready(function () {
    $("#roleForm").on("submit", function (event) {

  event.preventDefault();


  let role = $("#roles_name").val();
  let desc = $("#description").val();
  let update_id = $("#update_id").val();

  let sendingData = {}

  if (btnAction == "Insert") {
    sendingData = {
      "role": role,
      "description": desc,
      "action": "register_roles"
    }

  } 
  else {
    sendingData = {
      "update_id": update_id,
      "role": role,
      "desc": desc,
      "action": "update_roles"
    }
  }



  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/roles.php",
    data: sendingData,
    success: function (data) {
      let status = data.status;
      let response = data.data;

      if (status) {
        swal("Good job!", response, "success");
        btnAction = "Insert";
        $("#roleForm")[0].reset();
        $("#roleModal").modal("hide");
        loadRoles();
      } else {
        swal("NOW!", response, "error");
      }

    },
    error: function (data) {
      console.log(data)
      swal("NOW!", response, "error");

    }

  })

})

});

function loadRoles() {

  $("#rolesTable thead").html('');
  $("#rolesTable tbody").html('');

  let sendingData = {
    action: "read_roles"
  };

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/roles.php",
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

        $("#rolesTable thead").append(th);
        $("#rolesTable tbody").append(tr);
      }
    },

    error: function () {
      console.error("Failed to load data");
    }
  });
}


function getRoleInfo(update_id) {

  let sendingData = {
    "action": "get_role_info",
    "update_id": update_id
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/roles.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;


      if (status) {

        btnAction = "update";

        $("#update_id").val(response['id']);
        $("#roles_name").val(response['name']);
        $("#description").val(response['description']);
    
        $("#roleModal").modal("show");




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


function deleteRoles(id) {

  let sendingData = {
    "action": "delete_role",
    "delete_id": id
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/roles.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;


      if (status) {

        swal("Good job!", response, "success");
        loadRoles();


      } else {
        swal("Error", response, "error");
      }

    },
    error: function (data) {

    }

  })
}

$("#rolesTable").on('click', "a.update_info", function () {
  let id = $(this).attr("update_id");
  getRoleInfo(id)
})


$("#rolesTable").on('click', "a.delete_info", function () {
  let id = $(this).attr("delete_id");
  if (confirm("Are you sure To Delete")) {
    deleteRoles(id)

  }

})
