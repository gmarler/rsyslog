# rsyslog Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/rsyslog.svg)](https://supermarket.chef.io/cookbooks/rsyslog)
[![CI State](https://github.com/sous-chefs/rsyslog/workflows/ci/badge.svg)](https://github.com/sous-chefs/rsyslog/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Installs and configures rsyslog to replace syslogd for client and/or server use. By default, the service will be configured to log to files on local disk. See the Recipes and Examples sections for other uses.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

### Platforms

- CentOS 7+ (incl. Rocky & Alma)
- Debian 10+
- Fedora
- OpenSUSE Leap
- SmartOS / OmniOS
- Ubuntu 18.04+

### Chef

- Chef 15.3+

### Other

To use the `recipe[rsyslog::client]` recipe, you'll need to set up the `rsyslog.server_search` or `rsyslog.server_ip` attributes. See the **Recipes** and **Examples** sections below.

## Attributes

See `attributes/default.rb` for default values.

- `node['rsyslog']['log_dir']` - If the node is an rsyslog server, this specifies the directory where the logs should be stored.
- `node['rsyslog']['working_dir']` - The temporary working directory where messages are buffered
- `node['rsyslog']['working_dir_mode']` - The temporary working directory access mode
- `node['rsyslog']['server']` - Determined automatically and set to true on the server.
- `node['rsyslog']['server_ip']` - If not defined then search will be used to determine rsyslog server. Default is `nil`. This can be a string or an array.
- `node['rsyslog']['server_search']` - Specify the criteria for the server search operation. Default is `role:loghost`.
- `node['rsyslog']['protocol']` - Specify whether to use `udp` or `tcp` for remote loghost. Default is `tcp`. To use both specify both in a string e.g. 'udptcp'.
- `node['rsyslog']['bind']` - Specify the address to which the server should be listening; only use with `node['rsyslog']['protocol'] = 'udp'` because the feature does not work with the `tcp` protocol ([more info](http://www.rsyslog.com/doc/master/configuration/modules/imtcp.html#caveats-known-bugs)).
- `node['rsyslog']['port']` - Specify the port which rsyslog should connect to a remote loghost.
- `node['rsyslog']['remote_logs']` - Specify whether to send all logs to a remote server (client option). Default is `true`.
- `node['rsyslog']['per_host_dir']` - "PerHost" directories for template statements in `35-server-per-host.conf`. Default value is the previous cookbook version's value, to preserve compatibility. See **server** recipe below.
- `node['rsyslog']['priv_seperation']` - Whether to use privilege separation or not.
- `node['rsyslog']['priv_user']` - User to run as when using privilege separation. Defult is `node['rsyslog']['user']`
- `node['rsyslog']['priv_group']` - Group to run as when using privilege separation. Defult is `node['rsyslog']['group']`
- `node['rsyslog']['max_message_size']` - Specify the maximum allowed message size. Default is 2k.
- `node['rsyslog']['user']` - Who should own the configuration files and directories
- `node['rsyslog']['group']` - Who should group-own the configuration files and directories
- `node['rsyslog']['dir_owner']` - Who should own the log directories
- `node['rsyslog']['dir_group']` - Who should group-own the log directories
- `node['rsyslog']['config_dir']['mode']` -  Mode that should be set when creating the configuration directory
- `node['rsyslog']['file_create_mode']` - Mode that should be set when creating log files
- `node['rsyslog']['dir_create_mode']` - Mode that should be set when creating log directories
- `node['rsyslog']['umask']` - Specify the processes umask
- `node['rsyslog']['defaults_file']` - The full path to the defaults/sysconfig file for the service.
- `node['rsyslog']['package_name']` - Specify rsyslog package name
- `node['rsyslog']['service_name']` - The platform-specific name of the service
- `node['rsyslog']['preserve_fqdn']` - Value of the `$PreserveFQDN` configuration directive in `/etc/rsyslog.conf`. Default is 'off' for compatibility purposes.
- `node['rsyslog']['high_precision_timestamps']` - Enable high precision timestamps, instead of the "old style" format. Default is 'false'.
- `node['rsyslog']['repeated_msg_reduction']` - Value of `$RepeatedMsgReduction` configuration directive in `/etc/rsyslog.conf`. Default is 'on'
- `node['rsyslog']['logs_to_forward']` - Specifies what logs should be sent to the remote rsyslog server. Default is all ( _._ ).
- `node['rsyslog']['default_log_dir']` - log directory used in `50-default.conf` template, defaults to `/var/log`
- `node['rsyslog']['default_facility_logs']` - Hash containing log facilities and destinations used in `50-default.conf` template.
- `node['rsyslog']['default_file_template']` - The name of a pre-defined log format template (ie - RSYSLOG_FileFormat), used for local log files.
- `node['rsyslog']['default_remote_template']` - The name of a pre-defined log format template (ie - RSYSLOG_FileFormat), used for sending to remote servers.
- `node['rsyslog']['templates']` - Allows a user to specify a dynamic filename and the format of the logs
- `node['rsyslog']['rate_limit_interval']` - Value of the $SystemLogRateLimitInterval configuration directive in `/etc/rsyslog.conf`. Default is nil, leaving it to the platform default.
- `node['rsyslog']['rate_limit_burst']` - Value of the $SystemLogRateLimitBurst configuration directive in `/etc/rsyslog.conf`. Default is nil, leaving it to the platform default.
- `node['rsyslog']['action_queue_max_disk_space']` - Max amount of disk space the disk-assisted queue is allowed to use ([more info](http://www.rsyslog.com/doc/queues.html)).
- `node['rsyslog']['enable_tls']` - Whether or not to enable TLS encryption. When enabled, forces protocol to `tcp`. Default is `false`.
- `node['rsyslog']['tls_driver']` -  Defaults to `ossl`.
- `node['rsyslog']['tls_ca_file']` - Path to TLS CA file. Required for both server and clients.
- `node['rsyslog']['tls_certificate_file']` - Path to TLS certificate file. Required for server, optional for clients.
- `node['rsyslog']['tls_key_file']` - Path to TLS key file. Required for server, optional for clients.
- `node['rsyslog']['tls_auth_mode']` - Value for `$InputTCPServerStreamDriverAuthMode`/`$ActionSendStreamDriverAuthMode`, determines whether client certs are validated. Defaults to `anon` (no validation).
- `node['rsyslog']['tls_permitted_peer']` - Value for `ActionSendStreamDriverPermittedPeer`, it narrows the list of the allowed hosts. Works with TLS only. Defaults to `nil`.
- `node['rsyslog']['use_local_ipv4']` - Whether or not to make use the remote local IPv4 address on cloud systems when searching for servers (where available). Default is 'false'.
- `node['rsyslog']['allow_non_local']` - Whether or not to allow non-local messages. If 'false', incoming messages are only allowed from 127.0.0.1\. Default is 'false'.
- `node['rsyslog']['custom_remote']` - Array of hashes for configuring custom remote server targets
- `node['rsyslog']['additional_directives']` - Hash of additional directives and their values to place in the main rsyslog config file
- `node['rsyslog']['local_host_name']` - permits to overwrite the system hostname with the one specified in the directive
- `node['rsyslog']['default_conf_file']` - If false it skips the creation of default configuration file 50-default.conf
- `node['rsyslog']['server_per_host_template']` - Template to use in the `rsyslog::server` recipe when creating the `35-server-per-host.conf` file
- `node['rsyslog']['server_per_host_cookbook']` - Cookbook name to get the `node['rsyslog']['server_per_host_template']` template from
- `node['rsyslog']['imfile']['KEY']` - Set `imfile` module parameters of label `KEY` to value. e.g. `PollingInterval`. Consult rsyslog documentation for valid entries.

## Recipes

### default

Installs the rsyslog package, manages the rsyslog service and sets up basic configuration for a standalone machine.

### client

Includes `recipe[rsyslog]`.

Uses `node['rsyslog']['server_ip']` or Chef search (in that precedence order) to determine the remote syslog server's IP address. If search is used, the search query will look for the first `ipaddress` returned from the criteria specified in `node['rsyslog']['server_search']`.

You can use `node['rsyslog']['custom_config']` to define custom entries for sending logs to remote servers. Available attributes:

```
    'server': Ip/hostname of remote syslog server (Required)
    'port': Port to send logs to
    'logs': Syslog log facilities to send (auth, authpriv, daemon, etc)
    'protocol': Can be tcp or udp
    'remote_template': Rsyslog template used for the messages
```

Example:

```ruby
node['rsyslog']['custom_remote'] = [
  { 'server' => '10.10.4.4', 'port' => '567', 'logs' => 'auth.*,mail.*', 'protocol' => 'udp', 'remote_template' => 'RSYSLOG_SyslogProtocol23Format'},
  { 'server' => '10.0.0.3', 'port' => '555', 'logs' => 'authpriv,daemon.*' }
]
```

The server key is required; if other keys are left out, the default global values will be used (eg `node['rsyslog']['port']` will be used if 'port' is omitted)

If the node itself is a rsyslog server ie it has `rsyslog.server` set to true then the configuration is skipped.

If the node had an `/etc/rsyslog.d/35-server-per-host.conf` file previously configured, this file gets removed to prevent duplicate logging.

Any previous logs are not cleaned up from the `log_dir`.

### server

Configures the node to be a rsyslog server. The chosen rsyslog server node should be defined in the `server_ip` attribute or resolvable by the specified search criteria specified in `node['rsyslog']['server_search]` (so that nodes making use of the `client` recipe can find the server to log to).

The `server` recipe will create the logs in attribute `node['rsyslog']['log_dir']`, and the configuration in `/etc/rsyslog.d/server.conf`. This recipe also removes any previous configuration to a remote server by removing the file `/etc/rsyslog.d/49-remote.conf`.

The cron job used in the previous version of this cookbook is removed, but it does not remove any existing cron job from your system (so it doesn't break anything unexpectedly). We recommend setting up logrotate for the logfiles instead.

The `log_dir` will be concatenated with `per_host_dir` to store the logs for each client. Modify the attribute to have a value that is allowed by rsyslogs template matching values, see the rsyslog documentation for this.

Directory structure:

```erb
<%= @log_dir %>/<%= @per_host_dir %>/"logfile"
```

For example for the system with hostname `www`:

```text
/srv/rsyslog/2011/11/19/www/messages
```

For example, to change this to just the hostname, set the attribute `node['rsyslog']['per_host_dir']` via a role:

```ruby
"rsyslog" => { "per_host_dir" => "%HOSTNAME%" }
```

At this time, the server can only listen on UDP _or_ TCP.

# Resources

## file_input

Configures a [text file input monitor](http://www.rsyslog.com/doc/imfile.html) to push a log file into rsyslog. Rsyslog must be installed to use this custom resource either using your own wrapper cookbook or the rsyslog::default recipe.

Properties:

- `name`: name of the resource, also used for the syslog tag. Required.
- `file`: file path for input file to monitor. Required.
- `priority`: config order priority. Defaults to `99`.
- `severity`: syslog severity. Must be one of `emergency`, `alert`, `critical`, `error`, `warning`, `notice`, `info` or `debug`. If  undefined, rsyslog interprets this as `notice`.
- `facility`: syslog facility. Must be one of `auth`, `authpriv`, `daemon`, `cron`, `ftp`, `lpr`, `kern`, `mail`, `news`, `syslog`, `user`, `uucp`, `local0`, ... , `local7`. If undefined, rsyslog interprets this as `local0`.
- `cookbook_source`: cookbook containing the template. Defaults to `rsyslog`.
- `template_source`: template file source. Defaults to `file-input.conf.erb`

# Usage

Use `recipe[rsyslog]` to install and start rsyslog as a basic configured service for standalone systems.

Use `recipe[rsyslog::client]` to have nodes log to a remote server (which is found via the `server_ip` attribute or by the recipe's search call -- see **client**)

Use `recipe[rsyslog::server]` to set up a rsyslog server. It will listen on `node['rsyslog']['port']` protocol `node['rsyslog']['protocol']`.

If you set up a different kind of centralized loghost (syslog-ng, graylog2, logstash, etc), you can still send log messages to it as long as the port and protocol match up with the server software. See **Examples**

Use `rsyslog_file_input` within your recipes to forward log files to your remote syslog server.

## Examples

A `base` role (e.g., roles/base.rb), applied to all nodes so they are syslog clients:

```ruby
name "base"
description "Base role applied to all nodes"
run_list("recipe[rsyslog::client]")
```

Then, a role for the loghost (should only be one):

```ruby
name "loghost"
description "Central syslog server"
run_list("recipe[rsyslog::server]")
```

By default this will set up the clients search for a node with the `loghost` role to talk to the server on TCP port 514\. Change the `protocol` and `port` rsyslog attributes to modify this.

If you want to specify another syslog compatible server with a role other than loghost, simply fill free to use the `server_ip` attribute or the `server_search` attribute.

Example role that sets the per host directory:

```ruby
name "loghost"
description "Central syslog server"
run_list("recipe[rsyslog::server]")
default_attributes(
  "rsyslog" => { "per_host_dir" => "%HOSTNAME%" }
)
```

Default rsyslog options are rendered for RHEL family platforms, in `/etc/rsyslog.d/50-default.conf` with other platforms using a configuration like Debian family defaults. You can override these log facilities and destinations using the `rsyslog['default_facility_logs']` hash.

```ruby
name "facility_log_example"
run_list("recipe[rsyslog::default]")
default_attributes(
  "rsyslog" => {
    "default_facility_logs" => {
      '*.info;mail.none;authpriv.none;cron.none' => "/var/log/messages",
      'authpriv' => '/var/log/secure',
      'mail.*' => '-/var/log/maillog',
      '*.emerg' => '*'
    }
  }
)
```

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
