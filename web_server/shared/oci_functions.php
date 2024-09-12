<?php

##############################################################################
# Connect Function
##############################################################################
  function Connect()
  { global $conn;
    global $db_user;
    global $db_pass;
    global $db_conn;
    $db_user = 'soccer_web';
    $db_pass = 'soccer_web';
    $db_conn = 'soccer_web';
#      $conn = @oci_connect($_SESSION[ 'connection' ][ 'user' ], $_SESSION[ 'connection' ][ 'password' ], $_SESSION[ 'connection' ][ 'service' ]);
      $conn = oci_connect($db_user, $db_pass, $db_conn);
      $err = oci_error();
      if (is_array($err))
      {
      echo "<BR>" . htmlspecialchars('Logon failed: ' . $err[ 'message' ]) . '<br />' . "<BR>\n";
      }
  }

##############################################################################
# Disconenct Function
##############################################################################
  function Disconnect()
  { global $conn;
    if ($conn)
    { $committed = oci_commit($conn);
      oci_close($conn);
    }
  }

##############################################################################
# OpenCursor Function
##############################################################################
  function OpenCursor($sql, $bind = false)
  { global $conn;
#    echo "<PRE>\n";
#    echo $sql;
#    echo "</PRE>\n";
    $cursor = oci_parse($conn, $sql);
    if (! $cursor)
    { $err = oci_error($conn);
      if (is_array($err))
      {
      echo "<BR>" . htmlspecialchars('Parse failed: ' . $err[ 'message' ]) . "<BR>\n";
          }
    }
    else
    { if (is_array($bind))
      foreach ($bind as $fieldname => $value)
        oci_bind_by_name($cursor, ':' . $fieldname, $bind[ $fieldname ], -1);
      $ok = oci_execute($cursor, OCI_DEFAULT);
      if (! $ok)
      { $err = oci_error($cursor);
        if (is_array($err))
        echo "<BR>" . htmlspecialchars('Execute failed: ' . $err[ 'message' ]) . "<BR>\n";
      }
    }
    return $cursor;
  }

##############################################################################
# CloseCursor Function
##############################################################################
  function CloseCursor($cursor)
  { if ($cursor)
    oci_free_statement($cursor);
  }

##############################################################################
# Main Body
##############################################################################
#  if ((! isset($_SESSION[ 'connection' ])) || isset($_REQUEST[ 'disconnect' ]))
#    NewSession();
#  if (isset($_REQUEST[ 'connection' ]))
#    if (is_array($_REQUEST[ 'connection' ]))
#    { NewSession();
#      if (isset($_REQUEST[ 'connection' ][ 'user' ]))
#        $_SESSION[ 'connection' ][ 'user' ] = substr(trim(preg_replace('/[^a-zA-Z0-9_-]/', '', $_REQUEST[ 'connection' ][ 'user' ])), 0, 32);
#      if (isset($_REQUEST[ 'connection' ][ 'password' ]))
#        $_SESSION[ 'connection' ][ 'password' ] = substr(trim(preg_replace('/[^a-zA-Z0-9_-]/', '', $_REQUEST[ 'connection' ][ 'password' ])), 0, 32);
#    }
?>
