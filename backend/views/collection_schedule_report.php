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

  <div class="card">
      <div class="card-header">
        <h5>Collection Schedule Report</h5>
        <span class="d-block m-t-5"> <code></code> </span>
        <form id="collectionScheduleReport">

          <div class="row">
            <div class="col-sm-6">
            <!-- <label for=""></label> -->
              <select name="type" id="type" class="form-control form-select">
                <option value="all">All</option>
                <option value="scheduled">scheduled</option>
                <option value="in_progress">In progress</option>
                <option value="completed">Completed</option>
              </select>
            </div>



            <!-- <div class="col-sm-4">
              <label for="">From date</label>
              <input type="date" name="from_date" id="from_date" class="form-control">
            </div>
            <div class="col-sm-4">
            <lael for="">To date</lael>
              <input type="date" name="to_date" id="to_date" class="form-control">
            </div> -->


            <div class="col-sm-4">
              <button type="submit" id="Adddnew" class="btn btn-info">SHow</button>
            </div>
          </div>
        </form>

        <div class="row">
          <div class="table-responsive" id="printt_Area">
            <!-- <img id="myImage" width="100%" ; height="300px" src="../../assets/img/report.jpg" class="mb-3"> -->

            <table class="table" id="collectionScheduleReportTable">
              <thead class="table-success">

              </thead>
              <tbody>


              </tbody>

            </table>

          </div>
          <div class="col-sm-4">
            <button id="printt_statement" class="btn btn-success ml-1"><i class="fa fa-print"></i>print</button>
            <button id="exportt_statement" class="btn btn-info mr-4"><i class="fa fa-file"></i>Export</button>
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