$("#to_date").attr("disabled", true);
$("#from_date").attr("disabled", true);
$("#exportt_statement").attr("disabled", true);
$("#printt_statement").attr("disabled", true);

$("#type").on("change", function () {
  if ($("#type").val() == 0) {
    $("#to_date").attr("disabled", true);
    $("#from_date").attr("disabled", true);
  } else {
    $("#to_date").attr("disabled", false);
    $("#from_date").attr("disabled", false);
  }
})


$("#printt_statement").on("click", function () {
  let printarea = document.querySelector("#printt_Area");


  let newwindow = window.open("");
  newwindow.document.write(`<html><head><title></title>`);
  newwindow.document.write(`<style media="print">
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@200&display=swap');
    body{
        font-family: 'Poppins', sans-serif;
    }

    table{
      width:100%;
  }

    th{
        background-color : #40E0D0 !important;
        color: white !important;
       
    }
      
    th , td{
        padding:10px !important;
        text-align: left !important;

    }

    th , td{
        
        border-bottom : 1px solid #ddd !important;
    }
    
    
    </style>`);
  newwindow.document.write(`</head><body>`);
  newwindow.document.write(printarea.innerHTML);
  newwindow.document.write(`</body></html>`);
  newwindow.print();
  newwindow.close();


})



$("#exportt_statement").on("click", function () {
  let file = new Blob([$('#printt_Area').html()], { type: "application/vnd.ms-excel" });
  let url = URL.createObjectURL(file);
  let a = $("<a />", {
    href: url,
    download: "print_report.xls"
  }).appendTo("body").get(0).click();
  e.preventDefault();

});


$("#BinCollectionReport").on("submit", function (event) {
    event.preventDefault();
  
    // Clear previous table
    $("#BinCollectionReportTable thead, #BinCollectionReportTable tbody").html("");
  
    let type = $("#type").val();
    let from_date = $("#from_date").val();
    let to_date = $("#to_date").val();
  
    let sendingData = {
      type: type,
      from: from_date,
      to: to_date,
      action: "Bin_Collection_Report"
    };
  
    $.ajax({
      method: "POST",
      dataType: "JSON",
      url: "../Api/collection_report.php",
      data: sendingData,
      success: function (data) {
        let status = data.status;
        let response = data.data;
  
        if (!status || !response.length) {
          // No data case
          $("#BinCollectionReportTable tbody").html(
            `<tr><td colspan="100%" style="text-align:center;">No data available</td></tr>`
          );
          return;
        }
  
        let tr = '';
        let th = '';
  
        // Build table header (once)
        th = "<tr>";
        for (let r in response[0]) {
          th += `<th>${r}</th>`;
        }
        th += "</tr>";
  
        // Build table rows
        response.forEach(res => {
          tr += "<tr>";
          for (let r in res) {
            tr += `<td>${res[r]}</td>`;
          }
          tr += "</tr>";
        });
  
        $("#BinCollectionReportTable thead").append(th);
        $("#BinCollectionReportTable tbody").append(tr);

        $("#exportt_statement").attr("disabled", false);
        $("#printt_statement").attr("disabled", false);
      },
      error: function () {
        $("#BinCollectionReportTable tbody").html(
          `<tr><td colspan="100%" style="text-align:center; color:red;">Error fetching data</td></tr>`
        );
      }
    });
  });




// function loadData() {
//   $("#BinCollectionReportTable tbody").html('');

//   let sendingData = {
//     "action": "get_booking_repo"
//   }

//   $.ajax({
//     method: "POST",
//     dataType: "JSON",
//     url: "Api/volunteers.php",
//     data: sendingData,

//     success: function (data) {
//       let status = data.status;
//       let response = data.data;
//       let html = '';
//       let tr = '';

//       if (status) {
//         response.forEach(res => {

//           th = "<tr>";
//           for (let r in res) {
//             th += `<th>${r}</th>`;
//           }

//           th += "</tr>";


//           tr += "<tr>";
//           for (let r in res) {

//             if (r == "status") {
//               if (res[r] == "paid") {
//                 tr += `<td><span class="badge badge-success">${res[r]}</span></td>`;
//               } else {
//                 tr += `<td><span class="badge badge-danger">${res[r]}</span></td>`;
//               }
//             } else {
//               tr += `<td>${res[r]}</td>`;
//             }

//           }

//           tr += "</tr>"

//         })

//         $("#BinCollectionReportTable thead").append(th);
//         $("#BinCollectionReportTable tbody").append(tr);
//       }

//     },
//     error: function (data) {

//     }

//   })
// }