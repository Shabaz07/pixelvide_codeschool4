function login(event) {
  event.preventDefault(); 

  const username = $('#username').val().trim();
  const password = $('#password').val().trim();

  if (!username || !password) {
    alert('Please enter both username and password.');
    return;
  }

  console.log("Sending:", { username, password }); 

  $.ajax({
    url: 'api/login.php',
    method: 'POST',
    dataType: 'json',
    data: {
      username: username,
      password: password
    },
    success: function (response) {
      console.log("Success Response:", response);
      if (response.success) {
        localStorage.setItem("admin_token", response.data.token);
        console.log("Token stored:", localStorage.getItem("admin_token"));
        window.location.href = 'admin.html';
      } else {
        alert(response.message || 'Invalid credentials!');
      }
    },
    error: function (xhr, status, error) {
      console.error("AJAX Error Status:", xhr.status, status, error);
      console.error("Response Text:", xhr.responseText);
      alert(xhr.responseJSON?.message || 'Something went wrong!');
    }
  });
}