# Copyright © 2019 The Trustees of Indiana University
# SPDX-License-Identifier: BSD-3-Clause
#
#@summary The aide class manages the installation and configuration of aide
#
# @example
#   include aide
#
# @param package
#   AIDE package name. Default is set to aide.
#
# @version
#   AIDE version for installation passed to Package::ensure. Default is set to latest.
#
# @conf_path
#   Location of AIDE configuration file.
#
# @db_path
#   Location of AIDE database file.
#
# @db_temp_path
#   Location of update AIDE database file.
#
# @gzip_dbout
#   Gzip the AIDE database file (may affect performance). Default is set to not gzip the database file.
#
# @aide_path
#   Location of aide binary.
#
# @config_template
#   Template to use for aide configuration.
#
# @aide_log
#   AIDE check output log.
#
# @syslogout
#   Enables logging to the system logging service AUTH facility and '/var/log/messages'.
#
# @hour
#   Hour of cron job to run.
#
# @minute
#   Minute of cron job to run.
#
# @nocheck
#   Whether to enable or disable scheduled checks.
#
# @mailto
#   Set this vaule to send email of results from aide --check in cron.
#
# @mail_only_on_changes
#   If mail_only_on_changes is set to true,
#   mails are only sent if changes are detected by AIDE.
#   By default this flag is set to false
#
# @init_timeout
#   Allows to adjust timeout of the "aide --init" run.
#   Puppet default exec timeout is 300 (which is also kept),
#   but this may be insufficient for more complex aide DBs.

class aide (
  $package              = $aide::params::package,
  $version              = $aide::params::version,
  $conf_path            = $aide::params::conf_path,
  $db_path              = $aide::params::db_path,
  $db_temp_path         = $aide::params::db_temp_path,
  $gzip_dbout           = $aide::params::gzip_dbout,
  $aide_path            = $aide::params::aide_path,
  $config_template      = $aide::params::config_template,
  $aide_log             = $aide::params::aide_log,
  $syslogout            = $aide::params::syslogout,
  $hour                 = $aide::params::hour,
  $minute               = $aide::params::minute,
  $nocheck              = $aide::params::nocheck,
  $mailto               = $aide::params::mailto,
  $mail_only_on_changes = $aide::params::mail_only_on_changes,
  $init_timeout         = $aide::params::init_timeout,
) inherits aide::params {

  # Used to throttle I/O and CPU load of AIDE.
  package { 'util-linux':
    ensure => 'present',
  }

  package { $package:
    ensure => $version,
  }

  -> class { '::aide::cron':
      aide_path            => $aide_path,
      cat_path             => $aide::params::cat_path,
      rm_path              => $aide::params::rm_path,
      mail_path            => $aide::params::mail_path,
      minute               => $minute,
      hour                 => $hour,
      nocheck              => $nocheck,
      mailto               => $mailto,
      mail_only_on_changes => $mail_only_on_changes,
      conf_path            => $conf_path,
      require              => Package[$package],
    }

  -> class { '::aide::config':
    conf_path       => $conf_path,
    db_path         => $db_path,
    db_temp_path    => $db_temp_path,
    gzip_dbout      => $gzip_dbout,
    aide_log        => $aide_log,
    syslogout       => $syslogout,
    config_template => $config_template,
    require         => Package[$package],
  }

  ~> class  { '::aide::firstrun':
    aide_path    => $aide_path,
    conf_path    => $conf_path,
    db_temp_path => $db_temp_path,
    db_path      => $db_path,
    init_timeout => $init_timeout,
    require      => Package[$package],
  }
}
