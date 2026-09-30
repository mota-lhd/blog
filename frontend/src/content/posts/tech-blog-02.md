---
title: "coolify hardening"
author: "elmouatassim"
date: "2026-09-29"
summary: "how to secure your coolify setup?"
tags: [
    "tech",
    "coolify",
    "hardening",
    "security",
    "tailscale",
    "cloudflare"
]
categories: [
    "tech",
    "hardening"
]
mermaid: true
weight: 1
id: "tech-blog-01"
series: ["tech", "coolify hardening"]
---

## architecture

the general architecture we are aiming for is illustrated in the diagram below. this architecture uses zero trust principles and reduces the attack surface to a minimum by keeping on the server no listening services on its public interface. we will be having a default firewall rule on the server that drops any incoming connection on any protocol. an attacker scanning the public ip would find every port filtered or closed. the only public entry points are the two tunnel endpoints (cloudflare tunnel for apps, tailscale for ssh and for the https-serve that handles the coolify admin ui). both are outbound-initiated from the server. ssh is reachable only from authenticated tailnet devices and through authentication and short lived provisioned credentials. no ssh keys are needed to be managed by end users.

```mermaid
flowchart TB
    subgraph PUBLIC["Public Internet"]
        Browser["Browser / User"]
    end

    subgraph CF["Cloudflare Edge"]
        CFEdge["Cloudflare Proxy<br/>(Universal SSL - louhaidia.info cert)<br/>Full (Strict)<br/><b>Identity-Aware Proxy</b>"]
    end

    subgraph IDP["Identity Providers"]
        Auth0["Auth0<br/>IdP for Cloudflare"]
        GitHub["GitHub<br/>IdP for Tailscale"]
    end

    subgraph TAILNET["Tailnet (Tailscale) — highlighted"]
        AdminWeb["Admin Browser<br/>(on tailnet)"]
        Admin["Admin Device<br/>(on tailnet)"]

        subgraph HOST["server-name (on tailnet)"]
            subgraph TUNNEL["Docker: coolify network"]
                CFD["cloudflared<br/>(cloudflare-tunnel)<br/>outbound-only"]
                APPS["Application Containers<br/>(backups, umami, immich, ...)"]
            end

            subgraph LOOPBACK["Localhost Bindings"]
                COOLIFY["Coolify Admin<br/>127.0.0.1:8000 -> container:8080"]
                SOKETI["Coolify Realtime<br/>127.0.0.1:6001 / :6002"]
            end

            subgraph TAILBIND["Tailnet Bindings"]
                TSServe["Tailscale Serve<br/>coolify.tailscale-network-id.ts.net:443<br/>(*.ts.net cert)<br/>tailnet-only<br/><i>Coolify Admin UI published here —<br/>NOT exposed to Internet</i>"]
                TS["tailscaled<br/>&lt;TAILNET_IPv4&gt;:443"]
                SSHD["sshd<br/>&lt;TAILNET_IPv4&gt;:22"]
            end
        end
    end

    Browser -->|"HTTPS :443"| CFEdge
    CFEdge -->|"OIDC/SAML"| Auth0
    CFEdge -->|"HTTPS (origin cert)<br/>SNI: *.louhaidia.info"| CFD
    CFD -->|"HTTPS over Docker network"| APPS

    AdminWeb -->|"HTTPS :443<br/>tailnet-only"| TSServe
    TSServe -->|"HTTP to loopback"| COOLIFY
    COOLIFY -.->|"internal proxy<br/>for WebSocket"| SOKETI

    Admin -.->|"WireGuard"| TS
    Admin -->|"SSH"| SSHD

    GitHub -->|"IdP for Tailscale SSO"| TS

    classDef public fill:#f9d5d5,stroke:#c33,stroke-width:2px,color:#000
    classDef cf fill:#fde0a8,stroke:#e08a00,stroke-width:2px,color:#000
    classDef idp fill:#e0d5f9,stroke:#6a3fbf,stroke-width:3px,color:#000
    classDef tailnet fill:#c8f7c8,stroke:#1f7a1f,stroke-width:4px,color:#000
    classDef tunnel fill:#d5e8f9,stroke:#1f6fb2,stroke-width:2px,color:#000
    classDef loop fill:#fff3c4,stroke:#b8860b,stroke-width:2px,color:#000

    class Browser public
    class CFEdge cf
    class Auth0,GitHub idp
    class AdminWeb,Admin,TSServe,TS,SSHD tailnet
    class CFD,APPS tunnel
    class COOLIFY,SOKETI loop

    style TAILNET fill:#e6ffe6,stroke:#1f7a1f,stroke-width:4px
    style IDP fill:#f3e5f5,stroke:#6a3fbf,stroke-width:3px
```

> no inbound ports are exposed on the host's public interface. public https apps are served through cloudflare tunnel ; the coolify admin ui is exposed via tailscale serve command and only within the tailscale network. ssh is also available only on tailscale network.

### sequence diagrams

a user who is using publicly available apps hosted on coolify will go through the following sequence. some apps will be available after passing the identity aware proxy in cloudflare. some others will be available directly. this is usefull for some apps that are used by administrators (backups, automations, etc.).

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant CF as Cloudflare Edge<br/>(Identity-Aware Proxy)
    participant Auth0 as Auth0<br/>(IdP)
    participant CFD as cloudflared
    participant App as App Container

    U->>CF: HTTPS request<br/>Host: n8n.louhaidia.info
    Note over CF: Terminate TLS<br/>Universal SSL cert
    CF->>CF: IAP checks session / access policy

    alt No valid session
        CF-->>U: 302 redirect to Auth0
        U->>Auth0: Authenticate
        Auth0-->>U: Redirect back with auth code
        U->>CF: Callback with auth code
        CF->>Auth0: Exchange code / validate
        Auth0-->>CF: Tokens + claims
    end

    Note over CF: IAP enforces access<br/>Auth0 is IdP only
    CF->>CFD: Forward over tunnel<br/>SNI: n8n.louhaidia.info
    Note over CFD: Match SNI to host
    CFD->>App: HTTPS over Docker network
    App-->>CFD: Response
    CFD-->>CF: Response
    CF-->>U: HTTPS response
```

this following diagram illustrates the steps an admin will go through in order to access the coolify admin dashboard. as this interface is highly sensitive, it is published only on tailscale network and not exposed on the internet.

```mermaid
sequenceDiagram
    autonumber
    participant A as Admin Browser<br/>(on tailnet)
    participant TF as Tailscale Serve<br/>coolify.tailscale-network-id.ts.net:443
    participant LP as 127.0.0.1:8000
    participant C as Coolify Container :8080
    participant S as Coolify Realtime<br/>127.0.0.1:6001/6002

    Note over A: Admin already on tailnet<br/>authenticated via GitHub IdP for Tailscale

    A->>TF: HTTPS request<br/>coolify.tailscale-network-id.ts.net
    Note over TF: Terminate TLS<br/>*.ts.net cert<br/>Tailscale Serve — tailnet-only<br/>❌ NOT exposed via Funnel on the internet
    TF->>LP: HTTP to loopback
    Note over LP: docker-proxy NAT
    LP->>C: Forward to container port 8080
    C-->>LP: Response (HTML + JS)
    LP-->>TF: Response
    TF-->>A: HTTPS response

    Note over A,S: Browser opens WebSocket<br/>proxied internally by Coolify
    A->>TF: WSS request (same origin)
    TF->>LP: Forward to loopback
    LP->>C: Forward to container port 8080
    C->>S: Internal proxy to soketi
    S-->>C: WebSocket upgrade
    C-->>A: WebSocket established
```

the last sequence diagram is to visualize the steps in place to authenticate using ssh protocol from a trusted device on the tailnet network.

```mermaid
sequenceDiagram
    autonumber
    participant A as Admin Device<br/>(on tailnet)
    participant GH as GitHub<br/>(IdP for Tailscale)
    participant TS as tailscaled<br/>(server-name, on tailnet)
    participant SSH as sshd<br/>(server-name, on tailnet)

    Note over A,GH: Admin authenticates to Tailscale<br/>via GitHub IdP (SSO)
    A->>GH: OIDC login
    GH-->>A: Identity asserted

    A->>TS: WireGuard handshake<br/>(tailnet join)
    TS-->>A: Tailnet established
    Note over TS: server-name reachable at<br/><TAILNET_IPv4>;

    A->>SSH: SSH to <TAILNET_IPv4>:22
    Note over SSH: Bound to tailnet interface only<br/>publickey authentication using short lived creds
    SSH-->>A: Shell (publickey only)
```

## tailscale

[go to tailscale](https://tailscale.com/) website and signup for a free account. when prompted to select an identity provider, choose what you are used to. i chose [github](https://github.com/). once you authorized tailscale to fetch some information from your identity provider, your tailnet is created.

the next step is to enroll your server in tailnet. you will need to run on your linux server:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh
```

this command generates a node key pair and prompts you to authenticate via your chosen identity provider. the `--ssh` flag tells tailscale to advertise ssh capability for this device. you will see a url in the output. open this url in your browser to authenticate the server with your identity provider account. after successful authentication, the server will appear on the machines page of your tailscale admin console. tailscale never sees your identity provider password ; it uses oidc to verify your identity through github.

when you run `ssh your-server`, the tailscale client on your machine intercepts the connection. instead of using standard ssh keys, it establishes a connection over the wire-guard mesh network. tailscale's own ssh server on the destination device then authenticates you based on the rules in your tailscale config. the result is a secure, encrypted connection that is authorized centrally, without you ever managing a ssh key.

you also need to define in access controls → policies the rules you want to apply to control access to ssh in the tunnel. first you need to define the general acl:

```json
    {
        "src": ["mota-lhd@github"],
        "dst": ["tag:vps"],
        "ip":  ["tcp:22"],
    }
```

then the specific rule for ssh:

```json
{
 "src":    ["mota-lhd@github"], // the user authorized to run ssh
 "dst":    ["tag:vps"],         // the destination of the ssh command
 "users":  ["linux-user"],      // which users on dst linux server the src has access to
 "action": "check",             // forces checking the authentication each 12 hours
}
```

you also need to make sure that ssh listens on to the tailnet ip address. to perform this, you can create a new customization config on your server by adding the following file at `/etc/ssh/sshd_config.d/hardening.conf` with these contents.

```none
ListenAddress <TAILNET_IPv4>
ListenAddress <TAILNET_IPv6>
```

> this file permissions must be 644 and owned by root:root. sshd silently ignores files that are group or world writable.

The main `/etc/ssh/sshd_config` needs the directory include.

```none
Include /etc/ssh/sshd_config.d/*.conf
...
```

> the Include must appear before any ListenAddress in the main config. sshd uses first-match-wins.

then running the following command will run browser authentication and connect you to your server without managing any ssh keys.

```bash
ssh linux-user@server-name
```

## cloudflare

### why?

tailscale funnel feature could have been used as an ingress for custom-domain apps to publish them on the internet. the problem is that it terminates tls with a `*.ts.net` certificate only. it cannot present a certificate for `louhaidia.info`, which causes ssl handshake errors when a custom domain points at the funnel endpoint.

cloudflare tunnels solve this because cloudflare's edge serves the `louhaidia.info` certificate to clients and connects to the origin over a separate trusted path.

### cloudflare daemon

to implement cloudflare on coolify server, we create a new coolify service (using the template) with the following docker-compose file.

```yaml
services:

  cloudflared:
    container_name: cloudflare-tunnel
    image: 'cloudflare/cloudflared:latest'
    restart: unless-stopped
    command: 'tunnel --protocol http2 --no-autoupdate run'
    environment:
      - 'TUNNEL_TOKEN=${CLOUDFLARE_TUNNEL_TOKEN}'
    healthcheck:
      test: [CMD, cloudflared, '--version']
      interval: 5s
      timeout: 20s
      retries: 10
    networks:
      - coolify

networks:
  coolify:
    external: true
```

> do not set `network_mode: host`. the container must be on the `coolify` network so docker's embedded dns can resolve backend service names.

> do not publish any ports. the tunnel is outbound-only.

> the token is stored in .env.

### cloudflare tunnel

after creating a free account in cloudflare, you will need to configure in cloudflare dashboard → networks → tunnels a new tunnel and then afterwards go into the newly created tunnel settings to create a new route.

| **subdomain** | **domain** | **service url** | **sni setting** |
| ----------- | -------- | ------------- | ------------- |
| `*` | `louhaidia.info` | `https://<backend>:443` | `Match SNI to host = Enabled` |

replace `<backend>` with the container name of the service that terminates tls for your apps (e.g. the coolify proxy container on the `coolify` network). you can publish everything on the wildcard subdomain.

> match sni to host is required so `cloudflared` forwards the original hostname (e.g. `photos.louhaidia.info`) as the tls sni to the backend, allowing wildcard certificate matching.

### origin certificate

we need to generate the ssl certificate we will use to serve apps from the coolify containers. in cloudflare dashboard → ssl/tls → origin server → create certificate:

* Key type: **RSA (2048)**
* Hostnames: `louhaidia.info`, `*.louhaidia.info`
* Validity: **15 years**

> **free-plan limitation:** \*.louhaidia.info covers exactly one level of subdomain. [deep.sub.louhaidia.info](http://deep.sub.louhaidia.info) requires Advanced Certificate Manager.

we then need to make our caddy reverse proxy use these files to terminate ssl/tls connections. files placed on the host **inside the data volume of the tls-terminating container**, which is mapped into that container at `/data/`:

```bash
chmod 644 /path/to/caddy/configs/data/certs/louhaidia.info.cert
chmod 600 /path/to/caddy/configs/data/certs/louhaidia.info.key
```

loading these files is done using a dynamic config in caddy that can be created using the coolify admin dashboard or using the terminal.

```bash
# file in /path/to/caddy/configs/dynamic/louhaidia-origin.caddy

(cloudflare_origin) {
    tls /data/certs/louhaidia.info.cert /data/certs/louhaidia.info.key
}

*.louhaidia.info {
    import cloudflare_origin
}

louhaidia.info {
    import cloudflare_origin
}
```

then you need to reload the proxy config using the following command

```bash
docker exec coolify-proxy \
       caddy reload --adapter caddyfile \
                    --config /config/caddy/Caddyfile.autosave
```

make sure you have also configured as follows these settings.

| **Setting** | **Location** | **Value** |
| --------- | ---------- | ------- |
| SSL/TLS encryption mode | SSL/TLS → Overview | Full (Strict) |
| Always Use HTTPS | SSL/TLS → Edge Certificates | Enabled |
| Wildcard CNAME | DNS | `*.louhaidia.info` → `<TUNNEL_UUID>.cfargotunnel.com` (proxied) |

> full (strict) is mandatory now that the origin presents a real, cloudflare-trusted certificate.

> the wildcard cname is created automatically when the route is created within the tunnel.

## coolify admin ui

the coolify admin ui is exposed on the tailscale local network through `tailscale serve`. this is separate from the cloudflare tunnel path, which handles the `louhaidia.info` apps.

### how?

the following sequence explains how this is performed in the background.

```mermaid
flowchart LR
    A["Admin Browser<br/>(on tailnet)<br/>auth via GitHub IdP"]
    TS["Tailscale Serve<br/>coolify.tailscale-network-id.ts.net:443<br/>(*.ts.net cert)<br/><b>tailnet-only</b><br/>❌ NOT exposed to Internet"]
    LP["127.0.0.1:8000<br/>(docker-proxy)"]
    C["Coolify Container<br/>:8080"]
    S["Coolify Realtime<br/>127.0.0.1:6001/6002"]

    A -->|"HTTPS :443<br/>tailnet-only"| TS
    TS -->|"HTTP to loopback"| LP
    LP -->|"NAT to container port"| C
    C -.->|"internal proxy"| S

    classDef tailnet fill:#c8f7c8,stroke:#1f7a1f,stroke-width:4px,color:#000
    classDef loop fill:#fff3c4,stroke:#b8860b,stroke-width:2px,color:#000
    classDef cont fill:#d5e8f9,stroke:#1f6fb2,stroke-width:2px,color:#000

    class A,TS tailnet
    class LP loop
    class C,S cont

    style A fill:#e6ffe6,stroke:#1f7a1f,stroke-width:4px
    style TS fill:#e6ffe6,stroke:#1f7a1f,stroke-width:4px
```

coolify container proxies web-socket traffic internally to the realtime service, so the browser only needs to reach the `serve` https url on port 443. no additional ports are exposed.

### coolify ports

first create a customization file for coolify docker-compose in `/data/coolify/source/docker-compose.custom.yml`

```yaml
services:
  coolify:
    ports: !override
    - "127.0.0.1:8000:8080"
  soketi:
    ports: !override
    - "127.0.0.1:6001:6001"
    - "127.0.0.1:6002:6002"
```

to apply this change, run the upgrade script.

```bash
/data/coolify/source/upgrade.sh
```

### serve command

first you would need to go to network -> services in tailscale admin ui and create a new service. let's call it coolify and this service will listen on tcp port 443.
then ssh into your server and run the following as `root`:

```bash
tailscale serve reset
# here svc:coolify will advertise the service using the previously created entity
tailscale serve --https 443 --service svc:coolify --bg http://127.0.0.1:8000
tailscale serve status
```

then to allow access to the newly created service available at `coolify.<tailnet-id>.ts.net` you would need to add the following in access controls -> policies.

```json
{
 "src": ["mota-lhd@github"],
 "dst": ["svc:coolify"],
 "ip":  ["tcp:443"],
}
```

## conclusion

we hardened the server from the public edge to the server. we managed to have no inbound ports on its public interface. public apps are served through cloudflare tunnel (outbound-only), the coolify admin ui and ssh are published only on tailnet. all coolify services are bound to 127.0.0.1. the result: no 0.0.0.0 listeners, two outbound-initiated public entry points and a verifiable security posture.

in the next article in this series, we'll discuss network segmentation between services on coolify network using docker networking, splitting the flat shared bridge into isolated segments so containers only reach the peers they need. that and along with some docker security best practices will complete the hardening story.
