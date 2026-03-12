loadUsers()
fillRoles();
fillArea();
btnAction = "Insert";

function fillRoles() {

  let sendingData = {
    "action": "fill_roles"
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/users.php",
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

        $("#role_id").append(html);


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
    "action": "fill_area"
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/users.php",
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

        $("#area_id").append(html);


      } else {
        displaymessage("error", response);
      }

    },
    error: function (data) {

    }

  })
}

$(document).ready(function () {
    $("#userForm").on("submit", function (event) {

  event.preventDefault();


  let role_id = $("#role_id").val();
  let fullname = $("#fullname").val();
  let phone = $("#phone").val();
  let email = $("#email").val();
  let area_id = $("#area_id").val();
  let password = $("#password").val();
  let update_id = $("#update_id").val();

  let sendingData = {}

  if (btnAction == "Insert") {
    sendingData = {
      "role_id": role_id,
      "fullname": fullname,
      "email": email,
      "phone": phone,
      "password": password,
      "area_id": area_id,
      "action": "register_user"
    }

  } 
  else {
    sendingData = {
      "update_id": update_id,
      "role_id": role_id,
      "fullname": fullname,
      "email": email,
      "phone": phone,
      "password": password,
      "area_id": area_id,
      "action": "update_users"
    }
  }



  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/users.php",
    data: sendingData,
    success: function (data) {
      let status = data.status;
      let response = data.data;

      if (status) {
        swal("Good job!", response, "success");
        btnAction = "Insert";
        $("#userForm")[0].reset();
        $("#userModal").modal("hide");
        loadUsers();





      } else {
        swal("NOW!", response, "error");
      }

    },
    error: function (data) {
      swal("NOW!", "something wrong", "error");

    }

  })

})

});


function loadUsers() {

  $("#userTable thead").html('');
  $("#userTable tbody").html('');

  let sendingData = {
    action: "read_users"
  };

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/users.php",
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

              if (res[r] === "active") statusClass = "badge bg-success";
              else if (res[r] === "inactive") statusClass = "badge bg-danger";

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

        $("#userTable thead").append(th);
        $("#userTable tbody").append(tr);
      }
    },

    error: function () {
      console.error("Failed to load data");
    }
  });
}

function getUsersInfo(update_id) {
  let sendingData = {
    "action": "get_user_info",
    "update_id": update_id
  }
  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/users.php",
    data: sendingData,

    success: function (data) {
      let status = data.status;
      let response = data.data;
      if (status) {

        btnAction = "update";

        $("#update_id").val(response['id']);
        $("#fullname").val(response['full_name']);
        $("#phone").val(response['phone']);
        $("#email").val(response['email']);
        // $("#password").val(response['password']);
        $("#area_id").val(response['area_id']);
        $("#role_id").val(response['role_id']);
        $("#userModal").modal("show");
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


function deleteUsers(id) {

  let sendingData = {
    "action": "delete_user",
    "delete_id": id
  }

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/users.php",
    data: sendingData,

    success: function (data) {
      console.log(data)
      let status = data.status;
      let response = data.data;

      if (status) {

        swal("Good job!", response, "success");
        loadUsers();


      } else {
        swal("Error", response, "error");
      }

    },
    error: function (data) {
      swal("Error!", "Something went wrong", "error");
    }

  })
}

$("#userTable").on('click', "a.update_info", function () {
  let id = $(this).attr("update_id");
  getUsersInfo(id)
})


$("#userTable").on('click', "a.delete_info", function () {
  let id = $(this).attr("delete_id");
  if (confirm("Are you sure To Delete")) {
    deleteUsers(id)

  }

})
