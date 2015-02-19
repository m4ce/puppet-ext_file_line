# Puppet extended file line resource

ext_file_line derives from the original file_line resource found in the Puppet standard library (https://github.com/puppetlabs/puppetlabs-stdlib)

The main advantage compared to the original file_line is the ability to use regex backreferences in the line attribute.

Additionally, a diff of the changes applied (or what would when in noop mode) will be displayed.

This resource is generally useful when a specific file format is not supported by any of the Augeas lenses. It's also particularly handy when you do not want to manage the full content of files as templates in Puppet.

## Usage
A typical example would be something like the following:

```
$value = "yes"
ext_file_line {"nscd_enable_cache_passwd":
  path => "/etc/nscd.conf",
  line => "\\1$value",
  match => '^(.*?enable-cache.*?passwd.*?)(yes|no)$';
}
```

## Contact
Matteo Cerutti - matteo.cerutti@hotmail.co.uk
