<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Login | Waste Care</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

  <style>
    body {
      min-height: 100vh;
      background: linear-gradient(135deg, #1f7a3f, #2ecc71);
      display: flex;
      align-items: center;
      justify-content: center;
      font-family: "Segoe UI", sans-serif;
    }

    .login-card {
      border-radius: 16px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    }

    .login-icon {
      width: 80px;
      height: 80px;
      background: #1f7a3f;
      color: #fff;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 2.5rem;
      margin: -60px auto 20px;
    }
  </style>
</head>
<body>

<div class="container">
  <div class="row justify-content-center">
    <div class="col-md-5 col-lg-4">
      <div class="card login-card p-4">

        <!-- ICON -->
        <div class="login-icon">
          <i class="bi bi-person-fill"></i>
        </div>

        <!-- TITLE -->
        <h4 class="text-center fw-bold mb-3">Login to Waste Care</h4> 

        <!-- FORM -->
        <form id="loginForm">

         <div class="col-sm-12">
            <div class="alert alert-success d-none" role="alert">
            This is a success alert—check it out!
            </div>
            <div class="alert alert-danger d-none" role="alert">
            This is a danger alert—check it out!
            </div>
        </div>

        
          <div class="mb-3">
            <label class="form-label">Email address</label>
            <div class="input-group">
              <span class="input-group-text">
                <i class="bi bi-envelope"></i>
              </span>
              <input type="email" class="form-control" placeholder="admin@wastecare.com" id="email" name="email" required>
            </div>
          </div>

          <div class="mb-3">
            <label class="form-label">Password</label>
            <div class="input-group">
              <span class="input-group-text">
                <i class="bi bi-lock"></i>
              </span>
              <input type="password" class="form-control" placeholder="••••••••" required id="password" name="password">
            </div>
          </div>

          <div class="d-flex justify-content-between align-items-center mb-3">
            <!-- <div class="form-check">
              <input class="form-check-input" type="checkbox" id="remember">
              <label class="form-check-label" for="remember">
                Remember me
              </label>
            </div> -->
            <a href="#" class="text-decoration-none text-success">
              Forgot password?
            </a>
          </div>

          <button class="btn btn-success w-100 py-2">
            Login
          </button>
        </form>

        <p class="text-center mt-4 mb-0">
          © 2024 Waste Care
        </p>

      </div>
    </div>
  </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<?php

include("../includes/scripts.php")
?>

</body>
</html>
