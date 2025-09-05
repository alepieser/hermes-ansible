## Hermes Ansible

Infrastructure-as-code to provision a Raspberry Pi 4 (Hermes) as a secure home server with private DNS, reverse proxy, VPN access, and lightweight monitoring.

### What this sets up
- **Unbound**: validating, recursive DNS resolver with DoT, DNSSEC, privacy defaults; listens on 127.0.0.1:5353.
- **AdGuard Home**: DNS filtering on port 53, UI behind Nginx; upstream = Unbound; EDNS Client Subnet disabled.
- **Nginx**: reverse proxy on 80/443, logs minimized for SD longevity.
- **Let's Encrypt**: Cloudflare DNS-01 for certificates (wildcard supported).
- **Tailscale**: remote access, Split DNS (`sagradafamilia.casa`), disable key expiry for device, auto-approve subnet routes, IP forwarding.
- **Firewall (UFW)**: exposes only required ports (22, 53/tcp+udp, 80, 443, 45876).
- **Beszel agent**: lightweight monitoring agent listening on 45876/TCP.

### Repository layout
- `playbooks/setup.yml`: main provisioning playbook (all roles).
- `playbooks/update.yml`: system updates via role `alepieser.system_updates`.
- `inventory/hosts.yml`: target host inventory (Hermes).
- `group_vars/all.yml`: non-secret configuration.
- `group_vars/all.vault.yml`: secrets (encrypted with Ansible Vault).
- `roles/`: role customizations for `unbound`, `aguard` (AdGuard Home), `nginx`, `letsencrypt`, `tailscale`, `beszel`.
- `requirements.yml`: external roles and collections (including `community.beszel`).
- `requirements.txt`: Python requirements (Ansible, linters).

### Prerequisites
- Python 3.10+ on your control machine.
- Ansible (installed via `requirements.txt`).
- Vault password for `group_vars/all.vault.yml`.

### Quick start
```bash
# 1) Create a virtualenv and install deps
python3 -m venv venv
venv/bin/pip install -r requirements.txt

# 2) Install Galaxy roles & collections
venv/bin/ansible-galaxy install -r requirements.yml --roles-path ./roles

# 3) Create or edit your vault
venv/bin/ansible-vault edit group_vars/all.vault.yml

# 4) Run full setup (enter vault password when prompted)
venv/bin/ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --ask-vault-pass
```

### Secrets to set in the vault
Set these keys in `group_vars/all.vault.yml`:
- `vault_adguard_password`: bcrypt hash for AdGuard Home admin.
- `vault_letsencrypt_email`, `vault_cloudflare_api_key` (and optional `vault_cloudflare_email`).
- `vault_tailscale_auth_key`, `vault_tailscale_api_key`.
- `vault_beszel_agent_public_key`, `vault_beszel_agent_token`.

### Important variables (non-secret)
Defined in `group_vars/all.yml` (edit as needed):
- `hermes_domain`: local domain for Unbound local zones.
- `unbound_local_zones`: local A records (e.g., `hermes.local`).
- `adguard_local_dns_records`: AdGuard rewrites for local services under `sagradafamilia.casa`.
- `proxies`: Nginx reverse proxies (AdGuard UI on 8080 exposed via TLS).
- `tailscale_enabled`, `tailscale_advertise_routes`, `tailscale_accept_routes`.
- `beszel_agent_hub_url`: Beszel Hub URL (e.g., `http://192.168.1.72:8090`).

### Roles and tags
Run subsets of the setup using tags:
```bash
# DNS stack
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --ask-vault-pass --tags unbound,aguard

# Reverse proxy & certificates
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --ask-vault-pass --tags nginx,letsencrypt

# VPN (Tailscale)
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --ask-vault-pass --tags tailscale

# Firewall
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --ask-vault-pass --tags firewall

# Monitoring (Beszel agent)
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --ask-vault-pass --tags beszel
```

### DNS design
- AdGuard listens on port 53 and forwards to Unbound at 127.0.0.1:5353.
- Unbound uses DoT, DNSSEC, QNAME minimization, and disables ECS.
- Local DNS:
  - Unbound `unbound_local_zones` for `*.local` records.
  - AdGuard rewrites for internal services under `sagradafamilia.casa`.
- Tailscale Split DNS ensures clients resolve private subdomains via AdGuard.

### Logging minimized for SD longevity
- Unbound: `logfile: /dev/null`, `verbosity: 0`.
- Nginx: `access_log off;`, `error_log /dev/null;`.
- Tailscale: log level error, no log file.
- AdGuard: tuned for minimal persistence (optimized retention, optional).

### Open ports (UFW)
- 22/tcp (SSH)
- 53/tcp, 53/udp (DNS via AdGuard)
- 80/tcp, 443/tcp (Nginx)
- 45876/tcp (Beszel agent)

### System updates
Use the dedicated playbook:
```bash
ansible-playbook -i inventory/hosts.yml playbooks/update.yml --ask-vault-pass
```

### Make targets
```bash
make venv        # create venv and install Python deps
make install     # install deps and Galaxy roles/collections
make lint        # ansible-lint (in venv)
make ci-lint     # ansible-lint + yamllint (in venv)
```

### CI
GitHub Actions workflow runs:
- Ansible playbook syntax check (`playbooks/setup.yml`).
- ansible-lint and yamllint.

### Conventional commits
Use conventional commits for all changes, e.g.:
- `feat(beszel): add agent role and firewall port`
- `fix(unbound): set verbosity to 0`
- `docs(readme): add quick start and roles overview`

### Troubleshooting
- Vault errors (decrypt/decrypt): ensure you pass `--ask-vault-pass` or configure a vault-id.
- Unbound restart failure: run `unbound-checkconf` on the target to locate syntax errors.
- Tailscale flags: consolidate options in a single `tailscale up` call; API is used for nameservers and Split DNS.
- Firewall rule updates: ensure `firewall_allowed_ports` contains desired ports; re-run with `--tags firewall`.
- Beszel token: token is injected via systemd drop-in (`Environment=TOKEN=...`); restart service after changes.

### Access
- AdGuard UI: behind Nginx at your configured hostname (e.g., `https://adguard.sagradafamilia.casa`).

### License
MIT (see LICENSE if present).


