<?php

require_once('./functions/validateToken.php');
require_once('./utils/response.php');

$userDetails = validateToken();
sendSuccessMessage("User Details", $userDetails);
