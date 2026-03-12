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
                            <h4 class="card-title">Create vehicles</h4>
                        </div>
                        <div class="col-sm-12 text-end">
                            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#vehiclesModal">
                              Add New vehicles
                            </button>
                        </div>
                    </div>
                  </div>
                  <div class="card-body">
                    <div class="table-responsive">
                      <table
                        id="vehiclesTable"
                        class="display table table-striped table-hover"
                      >
                        <thead class="table-danger">
                          <tr>
                            <th>ID</th>
                            <th>vehicles Code</th>
                            <th>Capacity</th>
                            <th>Area</th>
                            <th>Last Collected</th>
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
        <div class="modal fade" id="vehiclesModal" tavehiclesdex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">vehicles Table</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                
                <form id="vehiclesForm">

                    <input type="hidden" name="update_id" id="update_id"> 
                    <div class="row">
                        <div class="col-md-12">
                             <div class="form-group">
                                <label for="vehicle_number" class="form-label">vehicle Number</label>
                                <input type="text" class="form-control" id="vehicle_number" name="vehicle_number">
                            </div>
                        </div>

                        <div class="col-md-12">
                             <div class="form-group">
                                <label for="capacity" class="form-label">Capacity</label>
                                <input type="number" class="form-control" id="capacity" name="capacity">
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


