$(document).ready(function () {
  getMovieList('1');

    const movieNavLinkButtons = document.querySelectorAll('.movie-nav-link');
    movieNavLinkButtons.forEach(button => {
      button.addEventListener('click', function() {
        const movieId = this.value;
        getMovieList(movieId); 
      });
    });

  const token = localStorage.getItem('admin_token');
    let currentEmployeeId = null;

    if (!token) {
        alert("Token not found. Please log in.");
        window.location.href = 'login.html';
        return;
    }

  $(".content-section").hide();
  $("#movieList").show();
  $("#add-movie-modal").hide();

  $(".nav-link").removeClass("active");
  $('.nav-link:contains("Movie List")').addClass("active");

  $(".nav-link").on("click", function (e) {
    e.preventDefault();
    $(".nav-link").removeClass("active");
    $(this).addClass("active");
    $(".content-section").hide();

    var linkText = $(this).text().trim();
    switch (linkText) {
      case "Movie List":
        $("#movieList").show();
        break;
      case "Theater List":
        $("#theaterList").show();
        getTheaterList();
        break;
      case "Add Show":
        $("#addShow").show();
        break;
      case "Bookings":
        $("#bookingList").show();
        break;
    }
  });

  $("#sidebar-toggle").on("click", function () {
    $("#sidebar").toggleClass("d-none");
  });

//   populate movie table
  function getMovieList(movieId) {

    const map={"1":"bollywoodMovieList","2":"tollywoodMovieList","3":"hollywoodMovieList","4":"kidsMovieList"}

    $.ajax({
      url: "api/getMovies.php",
      method: "GET",
      data: { token: localStorage.getItem('admin_token'), movieId: movieId },
      dataType: "json",
      success: function (response) {
        if (response.status === 'success') {
          $(`#${map[movieId]}`).empty();
          response.data.forEach((list,index) => {
            const row = `
              <tr>
                <td>${index+1}</td>
                <td>${list.title}</td>
                <td>${list.release_date}</td>
                <td>${list.category}</td>
                <td>${list.genre}</td>
                <td>${list.actors}</td>
                <td>${list.status}</td>
                
              </tr>`;
            $(`#${map[movieId]}`).append(row);
          });
        } else {
          console.error("Error fetching movies:", response.message || "Unknown error");
          alert(response.message || "Failed to load movie list.");
        }
      },
      error: function (xhr, status, error) {
        console.error("AJAX Error:", status, error, xhr.responseText);
        alert("Something went wrong. Please try again.");
      },
    });
  }

//   populate theater table
function getTheaterList() {
    $.ajax({
      url: "api/getTheater.php",
      method: "GET",
      data: { token: localStorage.getItem('admin_token') },
      success: function (response) {
        console.log(response);
        response.data.forEach((list , index) => {
          console.log(list)
          const row = `
                    <tr>
                        <td>${index + 1}</td>
                        <td>${list.theater_name}</td>
                        <td>${list.location}</td>
                        <td>${list.screens}</td>
                        <td>${list.start_time}</td>
                        <td>${list.status}</td>
                    </tr>`;
          $("#renderTheaterList").append(row);
        });
      },
      error: function (xhr, status, error) {
        console.error("AJAX Error:", status, error, xhr.responseText);
        alert("Something went wrong. Please try again.");
      },
    });
  }

//   populate booking table
  function getBookingsList() {
    $.ajax({
      url: "api/getBookings.php",
      method: "GET",
      data: { token: token },
      dataType: "application/json",
      success: function (response) {
        response.data.forEach((list) => {
          const row = `
                    <td>
                        <tr>${list.id}</tr>
                        <tr>${list.coustmer_name}</tr>
                        <tr>${list.category}</tr>
                        <tr>${list.theater_title}</tr>
                        <tr>${list.movie_name}</tr>
                        <tr>${list.start_time}</tr>
                        <tr>${list.bookingStatus}</tr>
                        // <tr>
                        //     <button class="btn btn-sm btn-warning editBtnHoa" data-id="${list.id}">View</button>
                        // </tr>
                    </td>`;
          $("#renderBookingList").append(row);
        });
      },
      error: function (xhr, status, error) {
        console.error("AJAX Error:", status, error, xhr.responseText);
        alert("Something went wrong. Please try again.");
      },
    });
  }

//   add theater and move as a show
  $('#addShowBtn').click(function bookShow(e){
    e.preventDefault()
    const movieShowData ={
        token: localStorage.getItem('admin_token'), 
        categoryId : $(('#categoryId')).val().trim(),
        movieId : $('#movieTitle').val().trim(),
        theaterId : $('#theaterName').val().trim(),
        showTime : $('#showTime').val().trim(),
        screens : $('#screenNumber').val().trim(),
    }
    console.log(movieShowData);
    $.ajax({
        url: 'api/bookMovieShow.php',
        method: 'POST',
        data: movieShowData,
        dataType: 'json',
        success: function(response){
        },
        error: function (xhr, status, error) {
            console.error("AJAX Error:", status, error, xhr.responseText);
            alert("Something went wrong. Please try again.");
        }
    })
  })
});
