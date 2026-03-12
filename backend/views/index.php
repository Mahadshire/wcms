<?php
    session_start();

    if (!isset($_SESSION['email'], $_SESSION['role'])) {
        header("Location: login.php");
        exit();
    }
     if ($_SESSION['role'] === 'driver') {
        header("Location: driver.php");
        exit();
    }


    // if ($_SESSION['role'] === 'admin') {
    //     header("Location: dashboard.php");
    //     exit();
    // }

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
<?php
include("../config/conn.php")
?>
 
 <div class="container">

  <?php
  // TOTAL DRIVERS
  $drivers = $conn->query("
      SELECT COUNT(*) AS total 
      FROM vw_users 
      WHERE role_name = 'driver'
  ")->fetch_assoc()['total'];

  // TOTAL VEHICLES
  $vehicles = $conn->query("
      SELECT COUNT(*) AS total 
      FROM vehicles
  ")->fetch_assoc()['total'];

  // ACTIVE SCHEDULES
  $activeSchedules = $conn->query("
      SELECT COUNT(*) AS total 
      FROM collection_schedule 
      WHERE status IN ('scheduled','in_progress')
  ")->fetch_assoc()['total'];

  // COMPLETED SCHEDULES
  $completedSchedules = $conn->query("
      SELECT COUNT(*) AS total 
      FROM collection_schedule 
      WHERE status = 'completed'
  ")->fetch_assoc()['total'];
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
                          <i class="fas fa-users"></i>
                        </div>
                      </div>
                      <div class="col col-stats ms-3 ms-sm-0">
                        <div class="numbers">
                          <p class="card-category text-light">All Active Drivers</p>
                          <h4 class="card-title text-light"><?php echo $drivers?></h4>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-sm-6 col-md-3">
                <div class="card card-stats card-round bg bg-danger">
                  <div class="card-body">
                    <div class="row align-items-center">
                      <div class="col-icon">
                        <div
                          class="icon-big text-center icon-info bubble-shadow-small"
                        >
                          <i class="fas fa-shipping-fast"></i>
                        </div>
                      </div>
                      <div class="col col-stats ms-3 ms-sm-0">
                        <div class="numbers">
                          <p class="card-category text-light"> ALl Active Vehicles</p>
                          <h4 class="card-title text-light"><?php echo $vehicles?></h4>
                        </div>
                      </div>
                    </div>
                    
                  </div>
                </div>
              </div>
              <div class="col-sm-6 col-md-3">
                <div class="card card-stats card-round bg bg-secondary">
                  <div class="card-body">
                    <div class="row align-items-center">
                      <div class="col-icon">
                        <div
                          class="icon-big text-center icon-success bubble-shadow-small"
                        >
                          <i class="far fa-calendar-check"></i>
                        </div>
                      </div>
                      <div class="col col-stats ms-3 ms-sm-0">
                        <div class="numbers">
                          <p class="card-category text-light">Active Schedules</p>
                          <h4 class="card-title text-light"><?php echo $activeSchedules?></h4>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-sm-6 col-md-3">
                <div class="card card-stats card-round bg bg-primary">
                  <div class="card-body">
                    <div class="row align-items-center">
                      <div class="col-icon">
                        <div
                          class="icon-big text-center icon-secondary bubble-shadow-small"
                        >
                          <i class="fas fa-check-circle"></i>
                        </div>
                      </div>
                      <div class="col col-stats ms-3 ms-sm-0">
                        <div class="numbers">
                          <p class="card-category text-light">Completed Schedules</p>
                          <h4 class="card-title text-light"><?php echo $completedSchedules?></h4>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>


            <div class="row">
              <!-- <div class="col-md-4">
                <div class="card card-round">
                  <div class="card-body">
                    <div class="card-head-row card-tools-still-right">
                      <div class="card-title">New Customers</div>
                      
                    </div>
                    <div class="card-list py-4">
                      <div class="item-list">
                        <div class="avatar">
                          <img
                            src="/WCMS/assets/img/jm_denis.jpg"
                            alt="..."
                            class="avatar-img rounded-circle"
                          />
                        </div>
                        <div class="info-user ms-3">
                          <div class="username">Jimmy Denis</div>
                          <div class="status">Graphic Designer</div>
                        </div>
                        <button class="btn btn-icon btn-link op-8 me-1">
                          <i class="far fa-envelope"></i>
                        </button>
                        <button class="btn btn-icon btn-link btn-danger op-8">
                          <i class="fas fa-ban"></i>
                        </button>
                      </div>
                      <div class="item-list">
                        <div class="avatar">
                          <span
                            class="avatar-title rounded-circle border border-white"
                            >CF</span
                          >
                        </div>
                        <div class="info-user ms-3">
                          <div class="username">Chandra Felix</div>
                          <div class="status">Sales Promotion</div>
                        </div>
                        <button class="btn btn-icon btn-link op-8 me-1">
                          <i class="far fa-envelope"></i>
                        </button>
                        <button class="btn btn-icon btn-link btn-danger op-8">
                          <i class="fas fa-ban"></i>
                        </button>
                      </div>
                      <div class="item-list">
                        <div class="avatar">
                          <img
                            src="/WCMS/assets/img/talha.jpg"
                            alt="..."
                            class="avatar-img rounded-circle"
                          />
                        </div>
                        <div class="info-user ms-3">
                          <div class="username">Talha</div>
                          <div class="status">Front End Designer</div>
                        </div>
                        <button class="btn btn-icon btn-link op-8 me-1">
                          <i class="far fa-envelope"></i>
                        </button>
                        <button class="btn btn-icon btn-link btn-danger op-8">
                          <i class="fas fa-ban"></i>
                        </button>
                      </div>
                      <div class="item-list">
                        <div class="avatar">
                          <img
                            src="/WCMS/assets/img/chadengle.jpg"
                            alt="..."
                            class="avatar-img rounded-circle"
                          />
                        </div>
                        <div class="info-user ms-3">
                          <div class="username">Chad</div>
                          <div class="status">CEO Zeleaf</div>
                        </div>
                        <button class="btn btn-icon btn-link op-8 me-1">
                          <i class="far fa-envelope"></i>
                        </button>
                        <button class="btn btn-icon btn-link btn-danger op-8">
                          <i class="fas fa-ban"></i>
                        </button>
                      </div>
                      <div class="item-list">
                        <div class="avatar">
                          <span
                            class="avatar-title rounded-circle border border-white bg-primary"
                            >H</span
                          >
                        </div>
                        <div class="info-user ms-3">
                          <div class="username">Hizrian</div>
                          <div class="status">Web Designer</div>
                        </div>
                        <button class="btn btn-icon btn-link op-8 me-1">
                          <i class="far fa-envelope"></i>
                        </button>
                        <button class="btn btn-icon btn-link btn-danger op-8">
                          <i class="fas fa-ban"></i>
                        </button>
                      </div>
                      <div class="item-list">
                        <div class="avatar">
                          <span
                            class="avatar-title rounded-circle border border-white bg-secondary"
                            >F</span
                          >
                        </div>
                        <div class="info-user ms-3">
                          <div class="username">Farrah</div>
                          <div class="status">Marketing</div>
                        </div>
                        <button class="btn btn-icon btn-link op-8 me-1">
                          <i class="far fa-envelope"></i>
                        </button>
                        <button class="btn btn-icon btn-link btn-danger op-8">
                          <i class="fas fa-ban"></i>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div> -->
              
              <div class="col-md-12">
                <?php
// Example queries (change table name if needed)
$approved = mysqli_query($conn, "
SELECT w.id, w.full_name 'Reporter_name', w.phone, a.name 'district',  w.request_target, b.bin_code, w.status FROM waste_request w 
JOIN areas a ON w.area_id = a.id
JOIN bins b on w.bin_id = b.id
WHERE w.status='approved' ORDER by  w.id DESC LIMIT 5
");
$pending = mysqli_query($conn, "SELECT w.id, w.full_name 'Reporter_name', w.phone, a.name 'district',  w.request_target, w.address, w.status FROM waste_request w 
JOIN areas a ON w.area_id = a.id
WHERE w.status='pending' and w.request_target ='house_hold'  ORDER by  w.id DESC LIMIT 5");
$collected = mysqli_query($conn, "SELECT w.id, w.full_name 'Reporter_name', w.phone, a.name,'district', a.zone,  w.request_target, b.bin_code, w.status FROM waste_request w 
JOIN areas a ON w.area_id = a.id
JOIN bins b on w.bin_id = b.id
WHERE w.status='collected' ORDER by  w.id DESC LIMIT 5");
?>

<div class="card">
    <div class="card-header bg-danger">
        <h4 class="card-title text-light text-center">Last Waste Requests</h4>
    </div>

    <div class="card-body">

        <!-- Tabs -->
        <ul class="nav nav-pills nav-success mb-3" role="tablist">
            <li class="nav-item">
                <a class="nav-link active" data-bs-toggle="pill" href="#approved" role="tab">
                    Last Approved Bin Requests
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link" data-bs-toggle="pill" href="#pending" role="tab">
                    Last Pending House Hold Requests
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link" data-bs-toggle="pill" href="#collected" role="tab">
                   Last Collected Bins
                </a>
            </li>
        </ul>

        <!-- Tab Content -->
        <div class="tab-content">

            <!-- Approved Waste -->
            <div class="tab-pane fade show active" id="approved">
                <div class="table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead class="table-success">
                            <tr>
                                <th>ID</th>
                                <th>Reporter Name</th>
                                <th>Phone</th>
                                <th>Waste Type</th>
                                <th>District</th>
                                <th>Bin Code</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php while($row = mysqli_fetch_assoc($approved)) { ?>
                                <tr>
                                    <td><?= $row['id']; ?></td>
                                    <td><?= $row['Reporter_name']; ?></td>
                                    <td><?= $row['phone']; ?></td>
                                    <td><?= $row['request_target']; ?></td>
                                    <td><?= $row['district']; ?></td>
                                    <td><?= $row['bin_code']; ?></td>
                                    <td>
                                        <span class="badge bg-success">
                                            <?= ucfirst($row['status']); ?>
                                        </span>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Pending Waste -->
            <div class="tab-pane fade" id="pending">
                <div class="table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead class="table-warning">
                            <tr>
                                <th>ID</th>
                                <th>Reporter Name</th>
                                <th>Phone</th>
                                <th>Waste Type</th>
                                <th>District</th>
                                <th>Address</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php while($row = mysqli_fetch_assoc($pending)) { ?>
                                <tr>
                                    <td><?= $row['id']; ?></td>
                                    <td><?= $row['Reporter_name']; ?></td>
                                    <td><?= $row['phone']; ?></td>
                                    <td><?= $row['request_target']; ?></td>
                                    <td><?= $row['district']; ?></td>
                                    <td><?= $row['address']; ?></td>
                                    <td>
                                        <span class="badge bg-warning text-dark">
                                            <?= ucfirst($row['status']); ?>
                                        </span>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Collected Waste -->
            <div class="tab-pane fade" id="collected">
                <div class="table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead class="table-primary">
                            <tr>
                                <th>ID</th>
                                <th>Reporter Name</th>
                                <th>Phone</th>
                                <th>Waste Type</th>
                                <th>District</th>
                                <th>Zone</th>
                                <th>Bin Code</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php while($row = mysqli_fetch_assoc($collected)) { ?>
                                <tr>
                                    <td><?= $row['id']; ?></td>
                                    <td><?= $row['Reporter_name']; ?></td>
                                    <td><?= $row['phone']; ?></td>
                                    <td><?= $row['request_target']; ?></td>
                                    <td><?= $row['district']; ?></td>
                                    <td><?= $row['zone']; ?></td>
                                    <td><?= $row['bin_code']; ?></td>
                                    <td>
                                        <span class="badge bg-primary">
                                            <?= ucfirst($row['status']); ?>
                                        </span>
                                    </td>
                                </tr>
                            <?php } ?>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>

    </div>
</div>
						</div>

              <div class="col-md-12">
                <div class="card card-round">
                  <div class="card-header">
                    <div class="card-head-row card-tools-still-right">
                      <div class="card-title">Driver Activity Report</div>
                      
                    </div>
                  </div>
                  <div class="card-body p-0">
                    <div class="table-responsive">
                      <!-- Projects table -->

                      <?php
                      $query = "SELECT 
                      u.full_name AS driver,
                      COUNT(cs.id) AS total_collections
                      FROM collection_schedule cs
                      JOIN users u ON cs.driver_id = u.id
                      WHERE cs.status = 'completed'
                      GROUP BY u.full_name";

                      $result = $conn->query($query);

                      ?>

                      <table class="table align-items-center mb-0">
                        <thead class="thead-light">
                          <tr>
                            <th>Driver</th>
                            <th>Total Collections</th>
                          </tr>
                        </thead>
                        <tbody>
                        
                            <?php
                            if($result->num_rows > 0){
                              while($row = $result->fetch_assoc()){
                                ?>
                                <tr>
                                    <td><?php echo $row['driver']; ?></td>
                                    <td><?php echo $row['total_collections']; ?></td>
                                </tr>
                                <?php
                              }
                            }
                           else {
                                  ?>
                                          <tr>
                                              <td colspan="2">No records found</td>
                                          </tr>
                                  <?php
                                  }
                                  ?>

                          
                        </tbody>
                      </table>
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