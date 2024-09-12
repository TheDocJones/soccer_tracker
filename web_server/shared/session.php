<?php
##############################################################################
# CheckSession
##############################################################################
  function CheckSession()
  {
#   // Initialize session ID
#   $sid = '';
#
#   if (isset($_REQUEST[ 'sid' ]))
#     $sid = substr(trim(preg_replace('/[^a-f0-9]/', '', $_REQUEST[ 'sid' ])), 0, 13);
#
#   if ($sid == '')
#     $sid = uniqid('');
#
#   // Start PHP session
#   session_id($sid);
   session_name('SoccerTrackerTest');
   @session_start();

# = = = = =
#
# = = = = =
#  $_SESSION[ 'server_id'    ] = "";
#  $_SESSION[ 'character_id' ] = "";
#  $_SESSION[ 'class_id'     ] = "";
# = = = = =
#
# = = = = =
  }
?>
