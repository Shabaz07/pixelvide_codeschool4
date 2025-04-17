$(document).ready(function () {
  const token = localStorage.getItem("user_token");
  let categoryId = 1;

  $(".content-section").hide();
  $("#movieBookList").show();
  getMoviesToBook(categoryId);

  $(".nav-link").removeClass("active");
  $('.nav-link:contains("Movie List")').addClass("active");

  $(".nav-link").on("click", function (e) {
    e.preventDefault();
    $(".nav-link").removeClass("active");
    $(this).addClass("active");
    $(".content-section").hide();

    var linkText = $(this).text().trim();
    switch (linkText) {
      case "Book Your Ticket":
        $("#movieBookList").show();
        getMoviesToBook(categoryId);
        break;
      case "Offers":
        $("#offersTab").show();
        break;
      case "Gift Cards":
        $("#giftCardTab").show();
        break;
      case "Booking History":
        $("#bookingHistoryTab").show();
        break;
    }
  });

  $(".movie-nav-link").on("click", function () {
    categoryId = $(this).val();
    $(".movie-nav-link").removeClass("active");
    $(this).addClass("active");
    getMoviesToBook(categoryId);
  });
  

  $("#sidebar-toggle").on("click", function () {
    $("#sidebar").toggleClass("d-none");
  });

  function getMoviesToBook(categoryId) {
    const map = {
      1: "pills-allMovie",
      2: "pills-bollywood",
      3: "pills-tollywood",
      4: "pills-hollywood",
      5: "pills-kids",
    };
    $.ajax({
      url: "api/getMoviesUser.php",
      method: "GET",
      data: {
        token: localStorage.getItem("user_token"),
        categoryId: categoryId,
      },
      dataType: "json",
      success: function (response) {
        console.log(response);
        if (response.status === "success") {
          $(`#${map[categoryId]}`).empty();
          console.log("Appending to tab:", map[categoryId]);
          response.data.forEach((list) => {
            const card = `
                  <div class="card p-0 " style="width: 20rem;">
                                    <img src="${list.poster}" alt="" class="rounded">
                                    <div class="card-body">
                                    <h5 class="card-title d-flex">Title:<span class="">${list.title}</span></h5>
                                    <p class="card-text">Ratings:${list.rating}</p>
                                    <a href="#" class="btn btn-primary fw-bold w-100" data-bs-toggle="modal" data-bs-target="#movieSelect" >Book Ticket</a>
                                    </div>
                                </div>`;
            $(`#${map[categoryId]}`).append(card);
          });
        } else {
          console.error(
            "Error fetching movies:",
            response.message || "Unknown error"
          );
          alert(response.message || "Failed to load movie list.");
        }
      },
      error: function (xhr, status, error) {
        console.error("AJAX Error:", status, error, xhr.responseText);
        alert("Something went wrong. Please try again.");
      },
    });
  }

  $('#bookTicket').click(function(){
    theaterName = $('#theaterName').val().trim()
    showTime = $('#showTime').val().trim()

    
  })

});
