$(document).ready(function () {
  getMovieList('1');

    const movieNavLinkButtons = document.querySelectorAll('.movie-nav-link');
    movieNavLinkButtons.forEach(button => {
      button.addEventListener('click', function() {
        const categoryId = this.value;
        getMovieList(categoryId); 
      });
    });

  const token = localStorage.getItem('admin_token');

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
        getBookingsList();
        break;
    }
  });

  $("#sidebar-toggle").on("click", function () {
    $("#sidebar").toggleClass("d-none");
  });

//   populate movie table
  function getMovieList(categoryId) {

    const map={"1":"bollywoodMovieList","2":"tollywoodMovieList","3":"hollywoodMovieList","4":"kidsMovieList"}

    $.ajax({
      url: "api/getMovies.php",
      method: "GET",
      data: { token: localStorage.getItem('admin_token'), categoryId: categoryId },
      dataType: "json",
      success: function (response) {
        if (response.status === 'success') {
          $(`#${map[categoryId]}`).empty();
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
            $(`#${map[categoryId]}`).append(row);
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
      data: { token: localStorage.getItem('admin_token') },
      success: function (response) {
        response.data.forEach((list,index) => {
          const row = `
                    <tr>
                        <td>${index+1}</td>
                        <td>${list.customer_name}</td>
                        <td>${list.category}</td>
                        <td>${list.theater_title}</td>
                        <td>${list.movie_name}</td>
                        <td>${list.start_time}</td>
                        <td>${list.bookingStatus}</td>
                    </tr>`;
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

  //add movie
  $('#add-movie-submit').click(function bookShow(e){
    e.preventDefault()
      var file = $('#moviePosterCode')[0].files[0];
      var reader = new FileReader();
      reader.onloadend = function() {
        const addMovieData ={
          token: localStorage.getItem('admin_token'), 
          categoryId : $(('#addCategoryId')).val().trim(),
          movieTitle : $('#add-movie-name').val().trim(),
          movieGenre : $('#add-movie-genre').val().trim(),
          addActors : $('#add-actors').val().trim(),
          addReleaseDate : $('#add-rDate').val().trim(),
          addMovieDuration : $('#add-movie-duration').val().trim(),
          addMovieDescription : $('#add-movie-description').val().trim(),
          moviePoster:  reader.result
      }
      console.log(addMovieData);
        $.ajax({
        url: 'api/addMovie.php',
        method: 'POST',
        data: addMovieData,
        dataType: 'json',
        success: function(response){
        },
        error: function (xhr, status, error) {
            console.error("AJAX Error:", status, error, xhr.responseText);
            alert("Something went wrong. Please try again.");
        }
    })
      }
      reader.readAsDataURL(file);
  })

//add theater
  $('#add-theater-submit').click(function bookShow(e){
    e.preventDefault()
        const addTheaterData ={
          token: localStorage.getItem('admin_token'), 
          theaterName : $(('#add-theater-name')).val().trim(),
          theaterAdd : $('#add-theater-loc').val().trim(),
          addScreens : $('#add-screens').val().trim(),
          addShowTimes : $('#add-show-times').val().trim(),
      }
      console.log(addTheaterData);
        $.ajax({
        url: 'api/addTheater.php',
        method: 'POST',
        data: addTheaterData,
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
