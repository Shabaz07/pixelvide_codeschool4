function login(event) {
  event.preventDefault(); // Prevent form from submitting normally

  const username = $('#username').val().trim();
  const password = $('#password').val().trim();

  if (!username || !password) {
    alert('Please enter both username and password.');
    return;
  }

  console.log("Sending:", { username, password }); // Debug: Log request data

  $.ajax({
    url: 'api/login.php',
    method: 'POST',
    dataType: 'json',
    data: {
      username: username,
      password: password
    },
    success: function (response) {
      console.log("Success Response:", response); // Debug: Log successful response
      if (response.success) {
        localStorage.setItem("admin_token", response.data.token);
        console.log("Token stored:", localStorage.getItem("admin_token")); // Debug: Confirm token
        window.location.href = 'index.html';
      } else {
        alert(response.message || 'Invalid credentials!');
      }
    },
    error: function (xhr, status, error) {
      console.error("AJAX Error Status:", xhr.status, status, error); // Debug: Log detailed error
      console.error("Response Text:", xhr.responseText); // Debug: Log raw response
      alert(xhr.responseJSON?.message || 'Something went wrong!');
    }
  });
}