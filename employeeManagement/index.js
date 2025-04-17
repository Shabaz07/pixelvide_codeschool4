$(document).ready(function () {
    const token = localStorage.getItem('admin_token');
    let currentEmployeeId = null;

    if (!token) {
        alert("Token not found. Please log in.");
        window.location.href = 'login.html';
        return;
    }

    // Logout Function
    $('.nav-link:contains("Logout")').on('click', function(e) {
    e.preventDefault(); // Prevent default link behavior
    console.log("Logout clicked, clearing token...");
    localStorage.removeItem('admin_token'); // Remove the admin token
    alert("Logged out successfully!");
    window.location.href = 'login.html'; // Redirect to login page
    });

    // Sidebar Navigation Logic
    $('.content-section').hide();
    $('#employee-details').show();
    $('#view-hoa').hide();
    $('.nav-link').removeClass('active');
    $('.nav-link:contains("Employee Details")').addClass('active');

    $('.nav-link').on('click', function(e) {
        e.preventDefault();
        $('.nav-link').removeClass('active');
        $(this).addClass('active');
        $('.content-section').hide();
        
        var linkText = $(this).text().trim();
        switch(linkText) {
            case 'Employee Details':
                $('#employee-details').show();
                $('#view-hoa').hide();
                getEmployees();
                break;
            case 'Salary Details':
                $('#salary-details').show();
                $('#view-hoa').hide();
                getSalaries();
                break;
            case 'Reports':
                $('#reports').show();
                $('#view-hoa').hide();
                getReports();
                break;
            case 'HOA':
                $('#hoa').show();
                $('#hoaCard').show();
                $('#view-hoa').hide();
                break;
            case 'Leaves':
                $('#leaves').show();
                $('#view-hoa').hide();
                fetchLeaveRequests();
                break;
            case 'Settings':
                $('#settings').show();
                $('#view-hoa').hide();
                break;
        }
    });

    $('#sidebar-toggle').on('click', function() {
        $('#sidebar').toggleClass('d-none');
    });

    // Open Add Modal
    $('#add-emp-btn').on('click', function () {
        console.log("Opening add-modal");
        $('#add-modal').modal('show');
    });

    // Add Employee
    $('#add-emp-submit').on('click', function (e) {
        e.preventDefault();
        const empData = {
            emp_id: $('#add-emp-id').val().trim(),
            first_name: $('#add-first-name').val().trim(),
            last_name: $('#add-last-name').val().trim(),
            surname: $('#add-surname').val().trim(),
            doj: $('#add-doj').val(),
            dob: $('#add-dob').val(),
            gender: $('#add-gender').val(),
            phone: $('#add-phone').val().trim(),
            working_status: $('#add-working-status').val(),
            designation: $('#add-designation').val(),
            location: $('#add-location').val(),
            gross: $('#add-gross').val().trim(),
            token: token
        };

        console.log("Add empData:", empData);

        const requiredFields = ['emp_id', 'first_name', 'last_name', 'surname', 'doj', 'dob', 'gender', 'phone', 'working_status', 'designation', 'location', 'gross'];
        for (let field of requiredFields) {
            if (!empData[field]) {
                alert(`Please fill in all required fields. Missing: ${field.replace('_', ' ')}`);
                return;
            }
        }

        if (isNaN(empData.gross) || empData.gross <= 0) {
            alert("Gross salary must be a positive number.");
            return;
        }
        if (!/^\d{10}$/.test(empData.phone)) {
            alert("Phone number must be exactly 10 digits.");
            return;
        }

        $.ajax({
            url: './api/addEmp.php',
            type: 'POST',
            data: empData,
            dataType: 'json',
            success: function (response) {
                console.log("Add Response:", response);
                if (response.status === 'success') {
                    alert(response.message || "Employee added successfully!");
                    $('#add-modal').modal('hide');
                    $('#add-form')[0].reset();
                    getEmployees();
                } else {
                    alert("Error: " + (response.message || "Failed to add employee."));
                }
            },
            error: function (xhr, status, error) {
                console.error("AJAX Error:", status, error, xhr.responseText);
                alert("Something went wrong. Please try again.");
            }
        });
    });

    // Initial Load
    getEmployees();

    function getEmployees() {
        $.ajax({
            url: 'api/getEmp.php',
            method: 'GET',
            data: { token: token },
            dataType: 'json',
            success: function (response) {
                console.log("Employee Response:", response);
                if (response.status === 'success' && response.data?.length > 0) {
                    renderEmployeeTable(response.data);
                } else {
                    alert(response.message || "No employees found.");
                }
            },
            error: function (xhr) {
                console.error("AJAX Error:", xhr.responseText);
                alert("Failed to fetch employee data.");
            }
        });
    }

    function renderEmployeeTable(data) {
        const tbody = $("#employeeTable");
        tbody.empty();
        data.forEach((emp) => {
            const row = `
                <tr>
                    <td>${emp.id || ''}</td>
                    <td>${emp.name || ''}</td>
                    <td>${emp.dob || ''}</td>
                    <td>${emp.gender || ''}</td>
                    <td>${emp.phone || ''}</td>
                    <td>${emp.working_status || ''}</td>
                    <td>${emp.designation || ''}</td>
                    <td>${emp.location || ''}</td>
                    <td>
                        <button class="btn btn-sm btn-warning editBtn" data-id="${emp.id}">Edit</button>
                        <button class="btn btn-sm btn-danger deleteBtn" data-id="${emp.id}">Delete</button>
                    </td>
                </tr>`;
            tbody.append(row);
        });
        viewEmployee();
        deleteEmpData();
    }

    function viewEmployee() {
        $('.editBtn').off('click').on('click', function () {
            const emp_id = $(this).data("id");
            console.log("Edit button clicked for emp_id:", emp_id);

            $.ajax({
                url: 'api/viewEmp.php',
                method: 'GET',
                data: { token: token, emp_id: emp_id },
                dataType: 'json',
                success: function (response) {
                    console.log("View Employee Response:", response);
                    if (response.message === 'success' && response.data) {
                        const emp = response.data;
                        console.log("Populating view-modal with data:", emp);

                        // Populate modal fields
                        $('#view-emp-id').val(emp.id || '');
                        $('#view-first-name').val(emp.first_name || '');
                        $('#view-last-name').val(emp.last_name || '');
                        $('#view-surname').val(emp.surname || '');
                        $('#view-doj').val(emp.date_of_joining || '');
                        $('#view-dob').val(emp.date_of_birth || '');
                        $('#view-gender').val(emp.gender || '');
                        $('#view-phone').val(emp.phone || '');
                        $('#view-working-status').val(emp.working_status || '');
                        $('#view-designation').val(emp.designation || '');
                        $('#view-location').val(emp.location || '');
                        $('#view-gross').val(emp.gross || '');

                        // Check if modal exists and Bootstrap is working
                        if ($('#view-modal').length) {
                            console.log("view-modal found in DOM, attempting to show...");
                            $('#view-modal').modal('show');
                        } else {
                            console.error("view-modal not found in DOM!");
                            alert("Modal element #view-modal not found in the page!");
                        }
                    } else {
                        console.warn("Failed to load employee details:", response.message);
                        alert(response.message || "Failed to load employee details.");
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", status, error, xhr.responseText);
                    alert("Failed to fetch employee details: " + (xhr.responseText || "Unknown error"));
                }
            });
        });

        $('#update-emp-submit').off('click').on('click', function (e) {
            e.preventDefault();

            const empData = {
                emp_id: $('#view-emp-id').val().trim(),
                first_name: $('#view-first-name').val().trim(),
                last_name: $('#view-last-name').val().trim(),
                surname: $('#view-surname').val().trim(),
                doj: $('#view-doj').val(),
                dob: $('#view-dob').val(),
                gender: $('#view-gender').val(),
                phone: $('#view-phone').val().trim(),
                working_status: $('#view-working-status').val(),
                designation: $('#view-designation').val(),
                location: $('#view-location').val(),
                gross: $('#view-gross').val().trim(),
                token: token
            };

            console.log("Update empData:", empData);

            const requiredFields = ['emp_id', 'first_name', 'last_name', 'surname', 'doj', 'dob', 'gender', 'phone', 'working_status', 'designation', 'location', 'gross'];
            for (let field of requiredFields) {
                if (!empData[field]) {
                    alert(`Please fill in all required fields. Missing: ${field.replace('_', ' ')}`);
                    return;
                }
            }

            if (isNaN(empData.gross) || empData.gross <= 0) {
                alert("Gross salary must be a positive number.");
                return;
            }
            if (!/^\d{10}$/.test(empData.phone)) {
                alert("Phone number must be exactly 10 digits.");
                return;
            }

            $.ajax({
                url: 'api/updateEmp.php',
                type: 'POST',
                data: empData,
                dataType: 'json',
                success: function (response) {
                    console.log("Update Response:", response);
                    if (response.status === 'success') {
                        alert(response.message || "Employee updated successfully!");
                        $('#view-modal').modal('hide');
                        getEmployees();
                    } else {
                        alert("Error: " + (response.message || "Failed to update employee."));
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", status, error, xhr.responseText);
                    alert("Something went wrong. Please try again.");
                }
            });
        });
    }

    function deleteEmpData() {
        $('.deleteBtn').off('click').on('click', function () {
            const emp_id = $(this).data("id");
            if (confirm("Are you sure you want to delete this employee?")) {
                $.ajax({
                    url: 'api/delEmp.php',
                    method: 'POST',
                    data: { token: token, emp_id: emp_id },
                    dataType: 'json',
                    success: function (response) {
                        console.log("Delete Response:", response);
                        if (response.status === 'success') {
                            alert(response.message || "Employee deleted successfully!");
                            getEmployees();
                        } else {
                            alert("Error: " + (response.message || "Failed to delete employee."));
                        }
                    },
                    error: function (xhr) {
                        console.error("AJAX Error:", xhr.responseText);
                        alert("Request failed: " + xhr.statusText);
                    }
                });
            }
        });
    }

    function getSalaries() {
        $.ajax({
            url: 'api/getSalary.php',
            method: 'GET',
            data: { token: token },
            dataType: 'json',
            success: function (response) {
                console.log("Salary Response:", response);
                if (response.status === "success" && response.data?.length > 0) {
                    renderSalaryTable(response.data);
                    $('#no-results').addClass('d-none');
                    $('#showing-count').text(response.data.length);
                    $('#total-count').text(response.data.length);
                } else {
                    $('#salary-table-body').empty();
                    $('#no-results').removeClass('d-none');
                    alert(response.message || "No salary records found.");
                }
            },
            error: function (xhr) {
                console.error("AJAX Error:", xhr.responseText);
                alert("Failed to fetch salary data.");
            }
        });
    }

    function renderSalaryTable(data) {
        const tbody = $("#salary-table-body");
        tbody.empty();
        if (!data || data.length === 0) {
            $("#no-results").removeClass("d-none");
            $("#showing-count").text("0");
            $("#total-count").text("0");
            return;
        }
        $("#no-results").addClass("d-none");

        data.forEach((salary) => {
            const row = `
                <tr>
                    <td>${salary.id || ''}</td>
                    <td>${salary.month || ''}</td>
                    <td>${salary.year || ''}</td>
                    <td>${salary.paid_on || ''}</td>
                    <td>₹${salary.gross || '0'}</td>
                    <td>₹${salary.deduction || '0'}</td>
                    <td>₹${salary.net || '0'}</td>
                    <td>
                        <button class="btn btn-sm btn-secondary editSalaryBtn" 
                            data-id="${salary.salary_id}" 
                            data-employee-id="${salary.id}">View Slip</button>
                    </td>
                </tr>`;
            tbody.append(row);
        });

        $("#showing-count").text(data.length);
        $("#total-count").text(data.length);

        $('.editSalaryBtn').on('click', function () {
            const salaryId = $(this).data('id');
            currentEmployeeId = $(this).data('employee-id');
            fetchSalaryDetails(salaryId);
        });
    }

    function fetchSalaryDetails(salaryId) {
        $.ajax({
            url: 'api/viewSalary.php',
            method: 'GET',
            data: { token: token, salaryId: salaryId },
            dataType: 'json',
            success: function (response) {
                console.log("Full Response:", response);
                if (response.status === 'success' && response.data) {
                    populateModal(response.data);
                    $('#salarySlipModal').modal('show');
                } else {
                    alert(response.message || 'Failed to load salary details.');
                }
            },
            error: function (xhr) {
                console.error('AJAX Error:', xhr.responseText);
                alert('Failed to fetch salary details.');
            }
        });
    }

    function populateModal(data) {
        if (!data) {
            alert("No data found.");
            return;
        }

        $('#employeeName').text(data.name || 'N/A');
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        $('#salaryMonth').val(`${monthNames[parseInt(data.month) - 1]} ${data.year}`);

        $('#grossSalary').text(`₹${data.gross || '0'}`);
        $('#totalDeductions').text(`₹${data.deduction || '0'}`);
        $('#netSalary').text(`₹${data.net || '0'}`);

        const earningsBody = $('#earningsBody');
        const deductionsBody = $('#deductionsBody');
        earningsBody.empty();
        deductionsBody.empty();

        if (data.components && Array.isArray(data.components)) {
            data.components.forEach(c => {
                const row = `
                    <tr>
                        <td>${c.description || 'Unknown'}</td>
                        <td class="text-end">
                            <input type="number" class="form-control component-amount" 
                                data-id="${c.id}" value="${c.amount || '0'}" 
                                onchange="updateComponent(${c.id}, ${data.id}, this.value)">
                        </td>
                        <td class="text-center">
                            <button class="btn btn-sm btn-outline-danger btn-remove" 
                                onclick="removeComponent(${c.id}, ${data.id})">Remove</button>
                        </td>
                    </tr>
                `;
                if (c.type === 'earning') {
                    earningsBody.append(row);
                } else if (c.type === 'deduction') {
                    deductionsBody.append(row);
                }
            });
        }
    }

    $('#salaryMonth').on('change', function () {
        const [monthName, year] = $(this).val().split(' ');
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        const month = (monthNames.indexOf(monthName) + 1).toString();
        if (currentEmployeeId && month && year) {
            $.ajax({
                url: 'api/getSalary.php',
                method: 'GET',
                data: { token: token, employee_id: currentEmployeeId, month: month, year: year },
                dataType: 'json',
                success: function (response) {
                    if (response.status === 'success' && response.data) {
                        populateModal(response.data);
                    } else {
                        alert(response.message || 'No salary data for this month.');
                    }
                },
                error: function (xhr) {
                    console.error('AJAX Error:', xhr.responseText);
                    alert('Failed to fetch salary details.');
                }
            });
        }
    });

    window.updateComponent = function(detailId, salaryId, newAmount) {
        if (newAmount < 0) {
            alert("Amount cannot be negative.");
            return;
        }
        $.ajax({
            url: 'api/updateSalaryComponent.php',
            method: 'POST',
            data: { token: token, detailId: detailId, amount: newAmount },
            dataType: 'json',
            success: function (response) {
                if (response.status === 'success') {
                    fetchSalaryDetails(salaryId);
                } else {
                    alert(response.message || 'Failed to update component.');
                }
            },
            error: function (xhr) {
                console.error('Update Error:', xhr.responseText);
                alert('Failed to update component.');
            }
        });
    };

    window.removeComponent = function(detailId, salaryId) {
        if (confirm('Are you sure you want to remove this component?')) {
            $.ajax({
                url: 'api/deleteSalaryComponent.php',
                method: 'POST',
                data: { token: token, detail_id: detailId },
                dataType: 'json',
                success: function (response) {
                    if (response.status === 'success') {
                        fetchSalaryDetails(salaryId);
                    } else {
                        alert(response.message || 'Failed to delete component.');
                    }
                },
                error: function (xhr) {
                    console.error('Delete Error:', xhr.responseText);
                    alert('Failed to delete component.');
                }
            });
        }
    };

    $('#salarySlipModal').on('hidden.bs.modal', function () {
        getSalaries();
    });

    function fetchLeaveRequests() {
        $.ajax({
            url: 'api/getLeave.php',
            method: 'GET',
            data: { token: token },
            dataType: 'json',
            success: function (response) {
                console.log("Leave Response:", response);
                if (response.status) {
                    const $tableBody = $("#leaves table tbody");
                    $tableBody.empty();
                    $.each(response.data, function (index, leave) {
                        const statusClass = leave.status === 'Approved' ? 'text-success' : 
                                        leave.status === 'Rejected' ? 'text-danger' : 'text-warning';
                        
                        const backgroundColor = leave.status === 'Pending' ? 'background-color: yellow;' : '';
                        
                        let actionButtons = '';
                        if (leave.status === 'Pending') {
                            actionButtons = `
                                <button class="btn btn-sm btn-success me-1 approve-btn" 
                                        data-id="${leave.id}">Approve</button>
                                <button class="btn btn-sm btn-danger reject-btn" 
                                        data-id="${leave.id}">Reject</button>
                            `;
                        }

                        const row = `
                            <tr style="${backgroundColor}">
                                <td>L-${String(leave.id).padStart(3, '0')}</td>
                                <td>${leave.employee_name}</td>
                                <td>${leave.department}</td>
                                <td>${leave.leave_type}</td>
                                <td>${leave.from_date}</td>
                                <td>${leave.to_date}</td>
                                <td>${leave.days}</td>
                                <td>${leave.reason}</td>
                                <td>${leave.applied_on}</td>
                                <td class="${statusClass} leave-status" data-id="${leave.id}">${leave.status}</td>
                                <td class="action-cell" data-id="${leave.id}">
                                    ${actionButtons}
                                </td>
                            </tr>`;
                        $tableBody.append(row);
                    });

                    $('.approve-btn').on('click', function() {
                        const leaveId = $(this).data('id');
                        handleLeaveAction(leaveId, 'Approved');
                    });

                    $('.reject-btn').on('click', function() {
                        const leaveId = $(this).data('id');
                        handleLeaveAction(leaveId, 'Rejected');
                    });

                } else {
                    console.error("No success status in response:", response);
                    alert(typeof response.message === 'string' ? response.message : "Failed to load leave requests.");
                }
            },
            error: function (xhr, status, error) {
                console.error("AJAX Error loading leave data:", error, xhr.responseText);
                alert("Failed to fetch leave requests: " + (xhr.responseText || "Unknown error"));
            }
        });
    }

    window.handleLeaveAction = function(leaveId, status) {
        if (!confirm(`Are you sure you want to ${status.toLowerCase()} this leave request?`)) {
            return;
        }

        $.ajax({
            url: 'api/updateLeaveStatus.php',
            method: 'POST',
            data: {
                token: token,
                leave_id: leaveId,
                status: status
            },
            dataType: 'json',
            success: function (response) {
                console.log("Update Leave Response:", response);
                if (response.status === 'success') {
                    const $row = $(`tr td.leave-status[data-id="${leaveId}"]`).closest('tr');
                    const newStatusClass = status === 'Approved' ? 'text-success' : 'text-danger';
                    
                    $row.find('.leave-status')
                        .text(status)
                        .removeClass('text-warning text-success text-danger')
                        .addClass(newStatusClass);
                    
                    $row.find('.action-cell').empty();
                    $row.css('background-color', '');

                    alert(response.message || `Leave request ${status} successfully!`);
                } else {
                    alert(typeof response.message === 'string' ? response.message : `Failed to ${status.toLowerCase()} leave request.`);
                }
            },
            error: function (xhr, status, error) {
                console.error("AJAX Error updating leave status:", error, xhr.responseText);
                alert("Failed to update leave status: " + (xhr.responseText || "Unknown error"));
            }
        });
    };

    if ($('.nav-link:contains("Leaves")').hasClass('active')) {
        fetchLeaveRequests();
    }

    function getReports() {
        $.ajax({
            url: 'api/getReport.php',
            method: 'GET',
            data: { token: token },
            dataType: 'json',
            success: function (response) {
                console.log("Raw AJAX Response:", response);
                if (response.status === true && response.message && response.message.status === 'success' && response.message.data) {
                    console.log("Data to Populate:", response.message.data);
                    populateReports(response.message.data);
                } else {
                    const errorMessage = (response.message && response.message.message) 
                        ? response.message.message 
                        : "Failed to load report data.";
                    console.error("Response Error:", response);
                    alert(errorMessage);
                }
            },
            error: function (xhr) {
                console.error("AJAX Error:", xhr.responseText);
                alert("Failed to fetch report data: " + xhr.statusText);
            }
        });
    }

    function populateReports(data) {
        console.log("Populating Reports with Data:", data);
    
        $('#totalEmployees').text(data.totalEmployees || 'N/A');
        $('#avgMonthlySalary').text('₹' + (data.avgMonthlySalary || '0.00'));
        $('#avgYearlySalary').text('₹' + (data.avgYearlySalary || '0.00'));
    
        const monthlyRoleTable = $('#monthlySalaryByRoleTable');
        monthlyRoleTable.empty();
        if (data.monthlyByRole && data.monthlyByRole.length > 0) {
            data.monthlyByRole.forEach(row => {
                monthlyRoleTable.append(`
                    <tr>
                        <td>${row.role}</td>
                        <td>${row.employee_count}</td>
                        <td>₹${Number(row.avg_monthly_salary).toFixed(2)}</td>
                    </tr>
                `);
            });
        } else {
            console.log("No data for monthlyByRole");
            $('#no-results-monthly-role').removeClass('d-none');
        }
    
        const monthlyLocationTable = $('#monthlySalaryByLocationTable');
        monthlyLocationTable.empty();
        if (data.monthlyByLocation && data.monthlyByLocation.length > 0) {
            data.monthlyByLocation.forEach(row => {
                monthlyLocationTable.append(`
                    <tr>
                        <td>${row.location}</td>
                        <td>${row.employee_count}</td>
                        <td>₹${Number(row.avg_monthly_salary).toFixed(2)}</td>
                    </tr>
                `);
            });
        } else {
            console.log("No data for monthlyByLocation");
            $('#no-results-monthly-location').removeClass('d-none');
        }
    
        const yearlyRoleTable = $('#yearlySalaryByRoleTable');
        yearlyRoleTable.empty();
        if (data.yearlyByRole && data.yearlyByRole.length > 0) {
            data.yearlyByRole.forEach(row => {
                yearlyRoleTable.append(`
                    <tr>
                        <td>${row.role}</td>
                        <td>${row.employee_count}</td>
                        <td>₹${Number(row.avg_yearly_salary).toFixed(2)}</td>
                    </tr>
                `);
            });
        } else {
            console.log("No data for yearlyByRole");
            $('#no-results-yearly-role').removeClass('d-none');
        }
    
        const yearlyLocationTable = $('#yearlySalaryByLocationTable');
        yearlyLocationTable.empty();
        if (data.yearlyByLocation && data.yearlyByLocation.length > 0) {
            data.yearlyByLocation.forEach(row => {
                yearlyLocationTable.append(`
                    <tr>
                        <td>${row.location}</td>
                        <td>${row.employee_count}</td>
                        <td>₹${Number(row.avg_yearly_salary).toFixed(2)}</td>
                    </tr>
                `);
            });
        } else {
            console.log("No data for yearlyByLocation");
            $('#no-results-yearly-location').removeClass('d-none');
        }
    
        const monthlyRoles = data.monthlyByRole && data.monthlyByRole.length > 0 ? data.monthlyByRole : [];
        const monthlyLocations = data.monthlyByLocation && data.monthlyByLocation.length > 0 ? data.monthlyByLocation : [];
        const yearlyRoles = data.yearlyByRole && data.yearlyByRole.length > 0 ? data.yearlyByRole : [];
        const yearlyLocations = data.yearlyByLocation && data.yearlyByLocation.length > 0 ? data.yearlyByLocation : [];
    
        const monthlyCtx = document.getElementById('monthlySalaryChart');
        if (!monthlyCtx) {
            console.error("Canvas element 'monthlySalaryChart' not found in the DOM");
            return;
        }
        const monthlyChartContext = monthlyCtx.getContext('2d');
        if (window.monthlyChart) {
            window.monthlyChart.destroy();
        }
    
        console.log("Monthly Chart Role Data:", monthlyRoles.map(row => Number(row.avg_monthly_salary)));
        console.log("Monthly Chart Location Data:", monthlyLocations.map(row => Number(row.avg_monthly_salary)));
    
        window.monthlyChart = new Chart(monthlyChartContext, {
            type: 'bar',
            data: {
                labels: [...monthlyRoles.map(row => row.role), ...monthlyLocations.map(row => row.location)],
                datasets: [
                    {
                        label: 'By Role (Monthly)',
                        data: [...monthlyRoles.map(row => Number(row.avg_monthly_salary)), ...monthlyLocations.map(() => 0)],
                        backgroundColor: 'rgba(54, 162, 235, 0.5)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 1
                    },
                    {
                        label: 'By Location (Monthly)',
                        data: [...monthlyRoles.map(() => 0), ...monthlyLocations.map(row => Number(row.avg_monthly_salary))],
                        backgroundColor: 'rgba(255, 99, 132, 0.5)',
                        borderColor: 'rgba(255, 99, 132, 1)',
                        borderWidth: 1
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Roles and Locations'
                        }
                    },
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Monthly Salary (₹)'
                        },
                        ticks: {
                            callback: function(value) {
                                return '₹' + value.toLocaleString('en-IN');
                            }
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'top'
                    }
                }
            }
        });
    
        const yearlyCtx = document.getElementById('yearlySalaryChart');
        if (!yearlyCtx) {
            console.error("Canvas element 'yearlySalaryChart' not found in the DOM");
            return;
        }
        const yearlyChartContext = yearlyCtx.getContext('2d');
        if (window.yearlyChart) {
            window.yearlyChart.destroy();
        }
    
        console.log("Yearly Chart Role Data:", yearlyRoles.map(row => Number(row.avg_yearly_salary)));
        console.log("Yearly Chart Location Data:", yearlyLocations.map(row => Number(row.avg_yearly_salary)));
    
        window.yearlyChart = new Chart(yearlyChartContext, {
            type: 'bar',
            data: {
                labels: [...yearlyRoles.map(row => row.role), ...yearlyLocations.map(row => row.location)],
                datasets: [
                    {
                        label: 'By Role (Yearly)',
                        data: [...yearlyRoles.map(row => Number(row.avg_yearly_salary)), ...yearlyLocations.map(() => 0)],
                        backgroundColor: 'rgba(54, 162, 235, 0.5)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 1
                    },
                    {
                        label: 'By Location (Yearly)',
                        data: [...yearlyRoles.map(() => 0), ...yearlyLocations.map(row => Number(row.avg_yearly_salary))],
                        backgroundColor: 'rgba(255, 99, 132, 0.5)',
                        borderColor: 'rgba(255, 99, 132, 1)',
                        borderWidth: 1
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Roles and Locations'
                        }
                    },
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Yearly Salary (₹)'
                        },
                        ticks: {
                            callback: function(value) {
                                return '₹' + value.toLocaleString('en-IN');
                            }
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'top'
                    }
                }
            }
        });
    }
    $("#submitHoa").click(function getHoa(e){
        e.preventDefault()
        const hoaData= {
            hod: $('#nameOfHOD').val().trim(),
            year: $('#budgetYear').val().trim(),
            estScheme: $('#establishment').val().trim(),
            mjH: $('#MajorHead').val().trim(),
            smjH: $('#SubMajorHead').val().trim(),
            mnH: $('#MinorHead').val().trim(),
            gsH: $('#GroupSubHead').val().trim(),
            sH: $('#SubHead').val().trim(),
            dH: $('#DetailedHead').val().trim(),
            sdH: $('#SubDetailedHead').val().trim(),
            status: $('#ChargedVoted').val().trim(),
            token: token
        };
        $.ajax({
            url: 'api/insertHoa.php',
            method: 'POST',
            data: hoaData,
            dataType: 'json',
            success: function(response){
                $('#hoaCard').hide();
                $('#view-hoa').show();
                renderHoaList();
            },
            error: function (xhr, status, error) {
                console.error("AJAX Error:", status, error, xhr.responseText);
                alert("Something went wrong. Please try again.");

            }
        })
    });



    function renderHoaList(){
        $.ajax({
            url: 'api/getHao.php',
            method: 'GET',
            data: {token: token},
            dataType: 'json',
            success: function(response){
                response.data.forEach(list=>{
                    const row = `
                <tr>
                    <td>${list.id || ''}</td>
                    <td>${list.hoa || ''}</td>
                    <td>${list.hod_description || ''}</td>
                    <td>${list.estscheme_description || ''}</td>
                    <td>${list.description || ''}</td>
                    <td>${list.amount || ''}</td>
                    <td>${list.status || ''}</td>
                    <td>
                        <button class="btn btn-sm btn-warning editBtnHoa" data-id="${list.id}">View</button>
                    </td>
                </tr>`;
                $("#hoaTable").append(row)
                })
            },
            error: function (xhr, status, error) {
                console.error("AJAX Error:", status, error, xhr.responseText);
                alert("Something went wrong. Please try again.");
            }
        })
    }
});
