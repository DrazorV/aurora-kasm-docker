# Reverse proxy and authentication

KasmVNC authentication is disabled inside the container because this project
is intended to sit behind an authenticated reverse proxy such as Authelia.

Never expose port 8444 directly to the public Internet. Restrict it with a
firewall to the reverse proxy, or place Nginx Proxy Manager on the same private
Docker network.

## Nginx requirements

The upstream uses HTTPS with a locally generated certificate:

```nginx
proxy_pass https://aurora:8444;
proxy_ssl_verify off;

proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $http_connection;

proxy_buffering off;
proxy_request_buffering off;
proxy_cache off;

proxy_connect_timeout 60s;
proxy_read_timeout 3600s;
proxy_send_timeout 3600s;
```

Keep the existing Authelia `auth_request` location around this upstream.
