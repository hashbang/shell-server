## Note this repo is deprecated in favor of http://github.com/hashbang/shell-etc which is now what is in production.
## This is here for reference, until everything is migrated over.


# Hashbang shell-server

<http://github.com/hashbang/shell-server>

The configuration files for the public hashbang.sh shell server.  Edit our server!

## File Structure
* New User Configs Files
```
etc/skel
```
* Man Page
```
usr/local/man/man7
```
* Hashbang website
```
var/www/html
```

## Hosting an App 

Eventually, the latter parts will be automated and will require only pushing configs. But for now:

Pull down the shell-server repo.
```
git clone https://github.com/hashbang/shell-server.git shell-server
```

You will need to add to add a supervisord configuration file, use existing configs as an example:
```
cd shell-server
vim etc/supervisor/conf.d/<yourapp>.conf
```

Next add your nginx configuration. Existing confs yada yada:
```vim etc/nginx/sites-available/<yourapp>.hashbang.sh```


Now for where your application code will live. We will be using submodules and they will live in /var/www/html, this path should be referenced in the configs above.

```git submodule add .... /var/www/html```

Once all that is commited, a sudo user on hashbang will need to pull in the new changes, update the submodules, and restart the services supervisord and nginx. 

If all goes well your app should now be live on: <yourapp.hashbang.sh


