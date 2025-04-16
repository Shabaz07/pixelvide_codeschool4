$(document).ready(function() {
    // Initially hide all content sections except employee details
    $('.content-section').hide();
    $('#movieBookList').show();
    $('#view-hoa').hide();
    
    $('.nav-link').removeClass('active');
    $('.nav-link:contains("Movie List")').addClass('active');
    
    $('.nav-link').on('click', function(e) {
        e.preventDefault();
        $('.nav-link').removeClass('active');
        $(this).addClass('active');
        $('.content-section').hide();
        
        var linkText = $(this).text().trim();
        switch(linkText) {
            case 'Book Your Ticket':
                $('#movieBookList').show();
                break;
            case 'Offers':
                $('#offersTab').show();
                break;
            case 'Gift Cards':
                $('#giftCardTab').show();
                break;
            case 'Booking History':
                $('#bookingHistoryTab').show();
                break;
        }
    });
    
    $('#sidebar-toggle').on('click', function() {
        $('#sidebar').toggleClass('d-none');
    });

    

});