<?php
    session_start();

    if (!isset($_SESSION['email'], $_SESSION['role'])) {
        header("Location: login.php");
        exit();
    }


    // if ($_SESSION['role'] === 'admin') {
    //     header("Location: index.php");
    //     exit();
    // }
     if ($_SESSION['role'] === 'driver') {
        header("Location: driver.php");
        exit();
    }

?> 

<?php
include("../includes/head.php")
?>

<?php
include("../includes/sidebar.php")
?>

<?php
include("../includes/header.php")
?>
 
 <div class="container">
          <div class="page-inner">
           
            <div class="row">
              <div class="col-md-12">
                <div class="card">
                  <div class="card-header">
                    <div class="row">
                        <div class="col-sm-12">
                            <h4 class="card-title">Create User</h4>
                        </div>
                        <div class="col-sm-12 text-end">
                            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#userModal">
                              Add New User
                            </button>
                        </div>
                    </div>
                  </div>
                  <div class="card-body">
                    <div class="table-responsive">
                      <table
                        id="userTable"
                        class="display table table-striped table-hover"
                      >
                        <thead class="table-danger">
                          <tr>
                            <th>ID</th>
                            <th>Fullname</th>
                            <th>email</th>
                            <th>phone</th>
                            <th>role</th>
                            <th>area</th>
                            <th>status</th>
                            <th>Action</th>
                          </tr>
                        </thead>
                        <!-- <tfoot>
                          <tr>
                            <th>Name</th>
                            <th>Position</th>
                            <th>Office</th>
                            <th>Age</th>
                            <th>Start date</th>
                            <th>Salary</th>
                          </tr>
                        </tfoot> -->
                        <tbody>
                          
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            

            <!-- Button trigger modal -->
           

            <!-- Modal -->
        <div class="modal fade" id="userModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">user Table</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                
                <form id="userForm">

                    <input type="hidden" name="update_id" id="update_id"> 
                    <div class="row">
                        <div class="col-md-12">
                             <div class="form-group">
                                <label for="fullname" class="form-label">Full Name</label>
                                <input type="text" class="form-control" id="fullname" name="fullname">
                            </div>
                        </div>

                        <div class="col-md-12">
                             <div class="form-group">
                                <label for="phone" class="form-label">Phone</label>
                                <input type="text" class="form-control" id="phone" name="phone">
                            </div>
                        </div>

                        <div class="col-md-12">
                             <div class="form-group">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="email" name="email">
                            </div>
                        </div>

                        <div class="col-md-12">
                             <div class="form-group">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="password" name="password">
                            </div>
                        </div>

                        <div class="col-md-6">
                             <div class="form-group">
                                <label for="role" class="form-label">Role</label>
                                <select name="role_id" id="role_id" class="form-control">
                                  <option disabled selected value>Select role</option>
                                  
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                             <div class="form-group">
                                <label for="area" class="form-label">Area</label>
                                <select name="area_id" id="area_id" class="form-control">
                                  <option disabled selected value>Select Area</option>
                                  
                                </select>
                            </div>
                        </div>

                      
                         </div>

                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" name="insert" class="btn btn-primary">Save changes</button>
                    </div>
                </form>
                </div>
            </div>
            </div>


          </div>
        </div>

<?php
include("../includes/footer.php")
?>
<?php

include("../includes/scripts.php")
?>


