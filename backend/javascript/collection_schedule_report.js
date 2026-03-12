$("#exportt_statement").attr("disabled", true);
$("#printt_statement").attr("disabled", true);

// $("#type").on("change", function () {
//   if ($("#type").val() == 0) {
//     $("#to_date").attr("disabled", true);
//     $("#from_date").attr("disabled", true);
//   } else {
//     $("#to_date").attr("disabled", false);
//     $("#from_date").attr("disabled", false);
//   }
// })


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


$("#collectionScheduleReport").on("submit", function (event) {
    event.preventDefault();
  
    // Clear previous table
    $("#collectionScheduleReportTable thead, #collectionScheduleReportTable tbody").html("");
  
    let type = $("#type").val();

    let sendingData = {
      type: type,
      action: "collection_Schedule_Report"
    };
  
    $.ajax({
      method: "POST",
      dataType: "JSON",
      url: "../Api/collection_schedule_report.php",
      data: sendingData,
      success: function (data) {
        let status = data.status;
        let response = data.data;
  
        if (!status || !response.length) {
          // No data case
          $("#collectionScheduleReportTable tbody").html(
            `<tr><td colspan="100%" style="text-align:center;">No data available</td></tr>`
          );
          return;
        }
        

        $("#exportt_statement").attr("disabled", false);
        $("#printt_statement").attr("disabled", false);
  
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
  
              // ===== Status coloring =====
              if (r === "status") {
  
                let statusClass = "";
  
                if (res[r] === "completed") statusClass = "badge bg-success";
                else if (res[r] === "in_progress") statusClass = "badge bg-warning text-dark";
                else if (res[r] === "scheduled") statusClass = "badge bg-danger";
  
                tr += `<td><span class="${statusClass}">${res[r]}</span></td>`;
  
              } else {
  
                tr += `<td>${res[r]}</td>`;
  
              }
            }
  
            // ===== Action Buttons =====
            
  
            tr += "</tr>";
          });
  
        $("#collectionScheduleReportTable thead").append(th);
        $("#collectionScheduleReportTable tbody").append(tr);

        $("#exportt_statement").attr("disabled", false);
        $("#printt_statement").attr("disabled", false);
      },
      error: function () {
        $("#collectionScheduleReportTable tbody").html(
          `<tr><td colspan="100%" style="text-align:center; color:red;">Error fetching data</td></tr>`
        );
      }
    });
  });

