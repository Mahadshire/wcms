$("#loginForm").on("submit", function (e) {
  e.preventDefault();

  // get values from form
  let email = $("#email").val(); // this is email field
  let password = $("#password").val();

  let sendingData = {
    "action": "Login",
    "email": email,        // match backend PHP
    "password": password
  };

  $.ajax({
    method: "POST",
    dataType: "JSON",
    url: "../Api/login.php",
    data: sendingData,

    success: function (data) {
      if (data.status) {

        // ✅ redirect based on role
        if (data.role === "admin") {
          window.location.href = "index.php";
        } else if (data.role === "driver") {
          window.location.href = "driver.php";
        } else if (data.role === "supervisor") {
          window.location.href = "supervisor_dashboard.php";
        }

      } else {
        // ❌ show error message
        displayMessage("error", data.data);
        $("#username").val("");
        $("#password").val("");
      }
    },

    error: function () {
      displayMessage("error", "Server error. Please try again.");
    }

  });

});

// -------------------- Display messages --------------------
function displayMessage(type, message) {
  let success = document.querySelector(".alert-success");
  let error   = document.querySelector(".alert-danger");

  if (type === "success") {
    error.classList = "alert alert-danger d-none";
    success.classList = "alert alert-success";
    success.innerHTML = message;

    setTimeout(function () {
      success.classList = "alert alert-success d-none";
    }, 400);
  } else {
    error.classList = "alert alert-danger";
    error.innerHTML = message;
  }
}

// -------------------- Toggle password --------------------
// function togglePassword() {
//   const passwordInput = document.getElementById("password");
//   const icon = document.getElementById("togglePassword");

//   if (passwordInput.type === "password") {
//     passwordInput.type = "text";
//     icon.classList.remove("fa-eye");
//     icon.classList.add("fa-eye-slash");
//   } else {
//     passwordInput.type = "password";
//     icon.classList.remove("fa-eye-slash");
//     icon.classList.add("fa-eye");
//   }
// }
