 
<?php
    session_start();

    if (!isset($_SESSION['email'], $_SESSION['role'])) {
        header("Location: login.php");
        exit();
    }


    // if ($_SESSION['role'] === 'driver') {
    //     header("Location: driver.php");
    //     exit();
    // }

?>

<?php
include("../includes/head.php")
?>

<?php
include("../includes/driversidebar.php")
?>

<?php
include("../includes/header.php")
?>

<?php
include("../config/conn.php");
?>
 
 <div class="container">
 <?php
 
  include("../config/conn.php");
  $driverId = $_SESSION['id'];

  $mySchedules = $conn->query("
  SELECT COUNT(*) AS total
  FROM collection_schedule
  WHERE driver_id = $driverId")->fetch_assoc()['total'];

  $activeSchedules = $conn->query("
  SELECT COUNT(*) AS total
      FROM collection_schedule
      WHERE STATUS = 'scheduled' AND driver_id = $driverId")->fetch_assoc()['total'];

  $completedSchedules = $conn->query("
  SELECT COUNT(*) AS total
      FROM collection_schedule
      WHERE STATUS = 'completed' AND driver_id = $driverId")->fetch_assoc()['total'];

  $todayCollections = $conn->query("
  SELECT COUNT(*) AS total
    FROM collection_schedule
    WHERE driver_id = '$driverId'
    AND date(completed_at) = CURDATE()")->fetch_assoc()['total'];

  

?>


          <div class="page-inner">
           

            <div class="row">
              <div class="col-sm-6 col-md-3">
                <div class="card card-stats card-round bg bg-success">
                  <div class="card-body">
                    <div class="row align-items-center">
                      <div class="col-icon">
                        <div
                          class="icon-big text-center icon-primary bubble-shadow-small"
                        >
                          <i class="far fa-calendar-check"></i>
                        </div>
                      </div>
                      <div class="col col-stats ms-3 ms-sm-0">
                        <div class="numbers">
                          <p class="card-category text-white">Assigned Schedules</p>
                          <h4 class="card-title"><?php echo $mySchedules?></h4>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-sm-6 col-md-3">
                <div class="card card-stats card-round bg bg-warning">
                  <div class="card-body">
                    <div class="row align-items-center">
                      <div class="col-icon">
                        <div
                          class="icon-big text-center icon-success bubble-shadow-small"
                        >
                          <i class="fas fa-calendar-alt"></i>
                        </div>
                      </div>
                      <div class="col col-stats ms-3 ms-sm-0">
                        <div class="numbers">
                          <p class="card-category text-light">Active Schedules</p>
                          <h4 class="card-title"><?php echo $activeSchedules?></h4>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-sm-6 col-md-3">
                <div class="card card-stats card-round">
                  <div class="card-body">
                    <div class="row align-items-center">
                      <div class="col-icon">
                        <div
                          class="icon-big text-center icon-success bubble-shadow-small"
                        >
                          <i class="fas fa-th"></i>
                        </div>
                      </div>
                      <div class="col col-stats ms-3 ms-sm-0">
                        <div class="numbers">
                          <p class="card-category">Today's Collections</p>
                          <h4 class="card-title"><?php echo $todayCollections  ?></h4>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-sm-6 col-md-3">
                <div class="card card-stats card-round bg bg-info">
                  <div class="card-body">
                    <div class="row align-items-center">
                      <div class="col-icon">
                        <div
                          class="icon-big text-center icon-secondary bubble-shadow-small"
                        >
                          <i class="far fa-check-circle"></i>
                        </div>
                      </div>
                      <div class="col col-stats ms-3 ms-sm-0">
                        <div class="numbers">
                          <p class="card-category text-light">Completed Schedules</p>
                          <h4 class="card-title"><?php echo $completedSchedules?></h4>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
             <ul class="nav nav-pills mb-4" id="collectionTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active"
                    id="bins-tab"
                    data-bs-toggle="pill"
                    data-bs-target="#bins"
                    type="button"
                    role="tab">
                Bin Collection
            </button>
        </li>

        <li class="nav-item" role="presentation">
            <button class="nav-link"
                    id="household-tab"
                    data-bs-toggle="pill"
                    data-bs-target="#household"
                    type="button"
                    role="tab">
                Household Collection
            </button>
        </li>
    </ul>

    <!-- TAB CONTENT -->
    <div class="tab-content">

        <!-- ================= BIN COLLECTION TAB ================= -->
        <div class="tab-pane fade show active" id="bins" role="tabpanel">

            <div class="row">
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">
                            <h4 class="card-title">Select Schedule To Collect</h4>
                        </div>

                        <div class="card-body">
                            <select class="form-select" id="scheduleSelect">
                                <option disabled selected>-- Select Schedule --</option>
                                <option value="1">Schedule 1</option>
                            </select>

                            <button id="startScheduleBtn"
                                    class="btn btn-success mt-3 w-100"
                                    disabled>
                                Start Schedule
                            </button>

                            <button id="completeScheduleBtn"
                                    class="btn btn-primary mt-2 w-100"
                                    disabled>
                                Complete Schedule
                            </button>
                        </div>
                    </div>
                </div>

                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">
                            <h4 class="card-title">Bins to Collect</h4>
                        </div>

                        <div class="card-body">
                            <table id="FullBinsTable" class="table table-bordered">
                                <thead class="table-primary">
                                    <tr>
                                        <th>#</th>
                                        <th>Bin Code</th>
                                        <th>Area</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td colspan="4" class="text-center text-danger">
                                            You don't selected schedule or no full bin in this schedule
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                    </div>
                </div>
            </div>

        </div>

        <!-- ================= HOUSEHOLD COLLECTION TAB ================= -->
        <div class="tab-pane fade" id="household" role="tabpanel">

            <div class="row">
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-header">
                            <h4 class="card-title ">
                                Select House Hold Schedule To Collect
                            </h4>
                        </div>

                        <div class="card-body">
                            <select class="form-select" id="House_holdScheduleSelect">
                                <option disabled selected>-- Select Schedule --</option>
                                <option value="1">Schedule 1</option>
                            </select>

                            <button id="House_holdStartScheduleBtn"
                                    class="btn btn-success mt-3 w-100"
                                    disabled>
                                Start Schedule
                            </button>

                            <button id="House_holdCompleteScheduleBtn"
                                    class="btn btn-primary mt-2 w-100"
                                    disabled>
                                Complete Schedule
                            </button>
                        </div>
                    </div>
                </div>

                <div class="col-md-12 mt-3">
                    <div class="card">
                        <div class="card-header">
                            <h4 class="card-title">House Hold to Collect</h4>
                        </div>

                        <div class="card-body">
                            <table id="FullHouseHoldsTable" class="table table-bordered">
                                <thead class="table-primary">
                                    <tr>
                                        <th>#</th>
                                        <th>Area</th>
                                        <th>Address</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td colspan="4" class="text-center text-danger">
                                            You don't selected schedule or no households in this schedule
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                    </div>
                </div>
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