# CoreAPI PHP Image

It adds some needed components by any API that is done using CoreAPI framework.

It has the production ready configuration for PHP. If you plan to develop be sure that you overwrite some values of the opcache configuration.
Valid development values can be:

```
; When disabled, you must reset the OPcache manually or restart the webserver
; for changes to the filesystem to take effect. The frequency of the check is
; controlled by the directive "opcache.revalidate_freq".
; (default "1")
opcache.validate_timestamps = 1

; How often (in seconds) to check file timestamps for changes to the shared
; memory storage allocation. ("1" means validate once per second, but only once
; per request. "0" means always validate)
; (default "2")
opcache.revalidate_freq = 2

; If disabled, all PHPDoc comments are dropped from the code to reduce the size
; of the optimized code. Disabling "Doc Comments" may break some existing
; applications and frameworks (e.g. Doctrine, ZF2, PHPUnit)
; (default "1")
opcache.save_comments = 1
```
