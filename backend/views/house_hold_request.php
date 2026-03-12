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
                            <h4 class="card-title">House_Hold Collection Requests</h4>
                        </div>
                        <div class="col-sm-12 text-end">
                            <!-- <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#approveHouseHoldModal">
                              Add New Schedule
                            </button> -->
                        </div>
                    </div>
                  </div>
                  <div class="card-body">
                    <div class="table-responsive">
                      <table
                        id="house_hould_CollectionTable"
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
        <div class="modal fade" id="approveHouseHoldModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Approve House_Hold Request</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                
                <form id="houseHoldApprovelForm">

                    <!-- <input type="hidden" name="request_id" id="request_id">  -->
                    <div class="row">
                        <div class="col-md-12">
                             <div class="form-group">
                                <label for="schedule_date" class="form-label">Schedule date</label>
                                <input type="date" class="form-control" id="house_schedules_date" name="house_schedules_date">
                            </div>
                        </div>

                         <div class="col-md-12">
                             <div class="form-group">
                                <label for="vehicle" class="form-label">Vehicle</label>
                                <select name="houseVehicles" id="houseVehicles" class="form-control">
                                  <option disabled selected value>Select Vehicle</option>
                                  
                                </select>
                            </div>
                        </div>


                        <div class="col-md-12">
                             <div class="form-group">
                                <label for="driver" class="form-label">Driver</label>
                                <select name="houseDrivers" id="houseDrivers" class="form-control">
                                  <option disabled selected value>Select Driver</option>
                                  
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


