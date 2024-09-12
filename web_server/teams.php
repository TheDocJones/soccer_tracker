<?php
##############################
# Header
##############################
  @ini_set('display_errors', 0);
  include('/var/www/html/soccer-tracker/shared/oci_functions.php');
  include('/var/www/html/soccer-tracker/shared/session.php');
  CheckSession();
  Connect();
  global $conn;
##############################



##############################
# Main body
##############################
  echo '<!DOCTYPE html>' . "\n";
  echo '<HTML>' . "\n";
  echo '  <HEAD>' . "\n";
  echo '    <TITLE>' . "\n";
  echo '      Soccer Tracker - Teams' . "\n";
  echo '    </TITLE>' . "\n";
  echo '    <LINK rel=stylesheet type="text/css" href="/shared/soccer_tracker.css">' . "\n";
  echo '  </HEAD>' . "\n";
  echo '  <BODY>' . "\n";

  echo '    <TABLE CLASS="hoverTableData00" style="width:90%" align="CENTER" vspace="0" border="0" cellpadding="0">' . "\n";
  echo '      <TR>' . "\n";
  echo '        <TD CLASS="tblhead" COLSPAN="3"><B>Soccer Teams</B></TD>' . "\n";
  echo '      </TR>' . "\n";
  echo '      <TR>' . "\n";
  echo '        <TD class="colheadcenter"><B>League</B></TD>' . "\n";
  echo '        <TD class="colheadcenter"><B>Team</B></TD>' . "\n";
  echo '        <TD class="colheadcenter"><B>Stadium</B></TD>' . "\n";
  echo '      </TR>' . "\n";

  $sql = "SELECT l.league_nm" . "\n" .
         "      ,t.team_nm" . "\n" .
         "      ,s.stadium_nm" . "\n" .
         "      ,t.stadium_id" . "\n" .
         "      ,t.league_id" . "\n" .
         "      ,t.team_id" . "\n" .
         "  FROM teams t" . "\n" .
         "      ,leagues l" . "\n" .
         "      ,stadiums s" . "\n" .
         "  WHERE t.league_id = l.league_id" . "\n" .
         "    AND t.stadium_id = s.stadium_id" . "\n" .
         "  ORDER BY l.league_nm" . "\n" .
         "          ,t.team_nm";
#   echo "<PRE>\n";
#   echo $sql;
#   echo "</PRE>\n";

  $cursor = OpenCursor($sql);
  if ($cursor)
   while (true)
  { if (! ocifetchinto($cursor, $row, OCI_ASSOC | OCI_RETURN_LOBS))
      break;
#################################################
    echo '      <TR>' . "\n";
    echo '        <TD class="">' . $row['LEAGUE_NM'] . '</TD>' . "\n";
    echo '        <TD class="">' . $row['TEAM_NM'] . '</TD>' . "\n";
    echo '        <TD class="">' . $row['STADIUM_NM'] . '</TD>' . "\n";
    echo '      </TR>' . "\n";
#################################################
  }
  CloseCursor($cursor);

  echo '    </TABLE>' . "\n";

  Disconnect();

  echo '  </BODY>' . "\n";
  echo '</HTML>' . "\n";

?>
