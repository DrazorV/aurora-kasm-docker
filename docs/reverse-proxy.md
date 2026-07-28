# Reverse proxy and authentication

KasmVNC authentication is disabled inside the container because this project
is intended to sit behind an authenticated reverse proxy such as Authelia.

Never expose ports 8444 or 8445 directly to the public Internet. Restrict them
with a firewall to the reverse proxy, or place Nginx Proxy Manager on the same
private Docker network.

## Nginx requirements

The upstream uses HTTPS with a locally generated certificate:

```nginx
proxy_pass https://aurora-user1:8444;
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

## Routing two users

Run one container per user, with a distinct `/config` volume. After Authelia
authenticates the request, map its `Remote-User` response to one of the two
upstreams:

| Authenticated user | Upstream |
|---|---|
| First allowed user | `aurora-user1:8444` |
| Second allowed user | `aurora-user2:8444` |

Use a deny response for every username that is not explicitly mapped. Do not
send KasmVNC `Authorization` headers to the Authelia subrequest.
