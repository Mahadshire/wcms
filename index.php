<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Waste Care | Smart Waste Management</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">



    <!-- Fonts and icons -->
    <script src="assets/js/plugin/webfont/webfont.min.js"></script>
    <script>
      WebFont.load({
        google: { families: ["Public Sans:300,400,500,600,700"] },
        custom: {
          families: [
            "Font Awesome 5 Solid",
            "Font Awesome 5 Regular",
            "Font Awesome 5 Brands",
            "simple-line-icons",
          ],
          urls: ["assets/css/fonts.min.css"],
        },
        active: function () {
          sessionStorage.fonts = true;
        },
      });
    </script>

    <!-- CSS Files -->
    <link rel="stylesheet" href="assets/css/bootstrap.min.css" />
    <link rel="stylesheet" href="assets/css/plugins.min.css" />
    <link rel="stylesheet" href="assets/css/kaiadmin.min.css" />

    <!-- CSS Just for demo purpose, don't include it in your project -->
    <link rel="stylesheet" href="assets/css/demo.css" />

    <style>
        body { scroll-behavior: smooth; }

        /* HERO */
        .hero {
            min-height: 100vh;
            background: linear-gradient(rgba(0,0,0,.65), rgba(0,0,0,.65)),
            url("https://images.unsplash.com/photo-1604187351574-c75ca79f5807") center/cover no-repeat;
            color: white;
            display: flex;
            align-items: center;
        }

        .section { padding: 90px 0; }
        .bg-soft-green { background: #f2f8f5; }

        .icon-lg {
            font-size: 42px;
            color: #198754;
        }

        /* REQUEST SECTION */
        .request-bg {
            background: linear-gradient(rgba(0,0,0,.65), rgba(0,0,0,.65)),
            url("https://images.unsplash.com/photo-1618477461853-cf6ed80faba5") center/cover no-repeat;
            color: white;
        }

        footer {
            background: #0b5ed7;
            color: white;
        }

        footer a {
            color: #d1e7dd;
            font-size: 20px;
            margin: 0 8px;
        }

        /* ===== SIMPLE SMOOTH ANIMATIONS ===== */

        /* Fade + slide animation */
        @keyframes fadeUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Hero animation */
        .hero h1,
        .hero p,
        .hero a {
            animation: fadeUp 1.2s ease forwards;
        }

        .hero p {
            animation-delay: 0.3s;
        }

        .hero a {
            animation-delay: 0.6s;
        }

        /* Section animation */
        .section {
            animation: fadeUp 1s ease;
        }

        /* Service card hover effect */
        #services .shadow {
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        #services .shadow:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.15);
        }

        /* Button hover smooth */
        .btn {
            transition: all 0.3s ease;
        }

        .btn:hover {
            transform: translateY(-2px);
        }

    </style>
</head>
<body>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark bg-success fixed-top shadow">
    <div class="container">
        <a class="navbar-brand fw-bold" href="#">Waste Care</a>
        <button class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#nav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div id="nav" class="collapse navbar-collapse">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="#home">Home</a></li>
                <li class="nav-item"><a class="nav-link" href="#about">About</a></li>
                <li class="nav-item"><a class="nav-link" href="#services">Services</a></li>
                <li class="nav-item"><a class="nav-link" href="#request">Request</a></li>
                <li class="nav-item"><a class="nav-link" href="#contact">Contact</a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- HERO -->
<section id="home" class="hero text-center">
    <div class="container">
        <h1 class="display-4 fw-bold">Keeping Our Cities Clean,<br>One Pickup at a Time</h1>
        <p class="lead mt-4">
            Professional waste collection and smart recycling services for modern cities.
        </p>
        <a href="#request" class="btn btn-success btn-lg mt-4">Request Pickup</a>
    </div>
</section>

<!-- ABOUT -->
<section id="about" class="section bg-soft-green">
    <div class="container">
        <div class="row g-5 align-items-center">
            <div class="col-md-6">
                <h2 class="fw-bold">About Waste Care</h2>
                <p>
                    Waste Care provides efficient waste collection, recycling,
                    and smart city cleanup services to keep communities clean and healthy.
                </p>

                <h5 class="mt-4 text-success">Our Mission</h5>
                <p>
                    To ensure proper waste collection and disposal using reliable services
                    and community participation.
                </p>

                <h5 class="mt-3 text-success">Our Vision</h5>
                <p>
                    To build cleaner, safer, and smarter cities through sustainable
                    waste management solutions.
                </p>
            </div>

            <div class="col-md-6">
                <img src="https://images.unsplash.com/photo-1604187351574-c75ca79f5807"
                     class="img-fluid rounded shadow" alt="Waste collection workers">
            </div>
        </div>
    </div>
</section>

<!-- SERVICES -->
<section id="services" class="section">
    <div class="container text-center">
        <h2 class="fw-bold mb-5">Our Services</h2>
        <div class="row g-4">
            <div class="col-md-3">
                <div class="p-4 bg-white shadow rounded h-100">
                    <i class="bi bi-trash icon-lg"></i>
                    <h5 class="mt-3">Waste Collection</h5>
                    <p>Scheduled household and commercial garbage pickup.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="p-4 bg-white shadow rounded h-100">
                    <i class="bi bi-recycle icon-lg"></i>
                    <h5 class="mt-3">Recycling</h5>
                    <p>Sorting and recycling services to reduce landfill waste.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="p-4 bg-white shadow rounded h-100">
                    <i class="bi bi-cpu icon-lg"></i>
                    <h5 class="mt-3">Smart Bin Monitoring</h5>
                    <p>Technology-driven waste bin monitoring systems.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="p-4 bg-white shadow rounded h-100">
                    <i class="bi bi-people icon-lg"></i>
                    <h5 class="mt-3">City Cleanup</h5>
                    <p>Public space and community cleanup programs.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- REQUEST -->
<section id="request" class="section request-bg">
    <div class="container">
        <div class="row g-5 align-items-center">
            <div class="col-md-6">
                <h2 class="fw-bold">Request Waste Pickup</h2>
                <p class="mt-3">
                    Submit your waste collection request easily.
                    Our team will collect waste efficiently and responsibly.
                </p>
            </div>

            <div class="col-md-6">
               <form id="requestForm" class="bg-white text-dark p-4 rounded shadow">

    <!-- Full name -->
    <div class="mb-3">
        <input type="text"
               id="fullname"
               name="fullname"
               class="form-control"
               placeholder="Enter your Fullname">
    </div>

    <!-- Phone number -->
    <div class="mb-3">
        <input type="number"
               id="number"
               name="number"
               class="form-control"
               placeholder="Enter your phone number">
    </div>

    <!-- Waste type + District -->
    <div class="row">
        <div class="col-sm-6">
            <div class="mb-3">
                <select name="waste_type"
                        id="waste_type"
                        class="form-control">
                    <option disabled selected value="">Select Waste Type</option>
                    <option value="bin">Bin</option>
                    <option value="house_hold">House Hold</option>
                </select>
            </div>
        </div>

        <div class="col-sm-6">
            <div class="mb-3">
                <select name="district"
                        id="district"
                        class="form-control">
                    <option disabled selected value="">Select District</option>
                </select>
            </div>
        </div>
    </div>

    <!-- Address (HOUSE HOLD only) -->
    <div class="mb-3" id="addressGroup">
        <input type="text"
               name="address"
               id="address"
               class="form-control"
               placeholder="Enter your address">
    </div>

    <!-- Bin (BIN only) -->
    <div class="mb-3" id="binGroup">
        <select name="bin"
                id="bin"
                class="form-control">
            <option disabled selected value="">Select Bin</option>
        </select>
    </div>

    <!-- Submit -->
    <button type="submit" class="btn btn-success w-100">
        Submit Request
    </button>

</form>

            </div>
        </div>
    </div>
</section>

<!-- CONTACT -->
<section id="contact" class="section bg-soft-green">
    <div class="container">
        <h2 class="fw-bold text-center mb-5">Contact Us</h2>
        <div class="row g-4">
            <div class="col-md-6">
                <form class="bg-white p-4 shadow rounded">
                    <div class="mb-3">
                        <label class="form-label">Name</label>
                        <input type="text" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Message</label>
                        <textarea class="form-control" rows="4"></textarea>
                    </div>
                    <button class="btn btn-success w-100">Send Message</button>
                </form>
            </div>

            <div class="col-md-6">
                <iframe
                    src="https://www.google.com/maps?q=Mogadishu%20Somalia&output=embed"
                    width="100%" height="100%" style="border:0;" loading="lazy"></iframe>
            </div>
        </div>
    </div>
</section>

<!-- FOOTER -->
<footer class="py-4 text-center">
    <div class="container">
        <p>🌱 Smart waste collection for cleaner cities</p>
        <div class="mb-2">
            <a href="#"><i class="bi bi-facebook"></i></a>
            <a href="#"><i class="bi bi-twitter"></i></a>
            <a href="#"><i class="bi bi-instagram"></i></a>
        </div>
        <p class="mb-0">&copy; 2026 Waste Care</p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

 <script src="assets/js/core/jquery-3.7.1.min.js"></script>
    <script src="assets/js/core/popper.min.js"></script>
    <script src="assets/js/core/bootstrap.min.js"></script>

    <!-- jQuery Scrollbar -->
    <script src="assets/js/plugin/jquery-scrollbar/jquery.scrollbar.min.js"></script>

    <!-- Chart JS -->
    <script src="assets/js/plugin/chart.js/chart.min.js"></script>

    <!-- jQuery Sparkline -->
    <script src="assets/js/plugin/jquery.sparkline/jquery.sparkline.min.js"></script>

    <!-- Chart Circle -->
    <script src="assets/js/plugin/chart-circle/circles.min.js"></script>

    <!-- Datatables -->
    <!-- <script src="assets/js/plugin/datatables/datatables.min.js"></script> -->

    <!-- Bootstrap Notify -->
    <script src="assets/js/plugin/bootstrap-notify/bootstrap-notify.min.js"></script>

    <!-- jQuery Vector Maps -->
    <script src="assets/js/plugin/jsvectormap/jsvectormap.min.js"></script>
    <script src="assets/js/plugin/jsvectormap/world.js"></script>

    <!-- Sweet Alert -->
    <script src="assets/js/plugin/sweetalert/sweetalert.min.js"></script>

    <!-- Kaiadmin JS -->
    <script src="assets/js/kaiadmin.min.js"></script>

    <script src="backend/javascript/request.js"></script>

    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>


   


 <!-- <script src="/javascript/roles.js"></script>  -->


</body>
</html>
