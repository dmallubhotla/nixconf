# Docker in OpenClaw: Feature Branch Proposal

## Goal
Enable unprivileged Docker builds and container operations within OpenClaw agents, specifically for the bommalata project and future containerized workflows.

## Current State

### Host (nixosVM)
- QEMU/KVM-based NixOS system
- **Docker configured in `commonVM-configuration.nix`** with rootless mode
- OpenClaw runs directly in VM as `smriti` user (not containerized)
- Simpler architecture: no container-to-container socket mounting needed

### Production Context (Future K8s Deployment)
- When bommalata runs in Kubernetes pods, will need socket mounting
- This proposal covers both current VM setup and future K8s architecture

### Current Status
- Docker is configured with `withDocker = true` in nixosVM definition
- Rootless Docker enabled in `commonVM-configuration.nix`
- **Missing**: `smriti` user not yet in `docker` group (this PR adds it)

## Proposed Solution: Unprivileged Docker Architecture

### Design Principles
1. **Rootless by default** — Use Docker's rootless mode on the host
2. **Least privilege** — OpenClaw container user gets minimal necessary permissions
3. **Isolation** — Docker operations contained within user namespace
4. **No privileged escalation** — No `sudo`, no `CAP_SYS_ADMIN`, no privileged containers

### Implementation Plan

#### Phase 1: Enable Rootless Docker on Host ✅ (Already in master)

**Status:** Docker rootless configuration already exists in `commonVM-configuration.nix`

```nix
# From commonVM-configuration.nix
virtualisation.docker = lib.mkIf withDocker {
  enable = true;
  rootless = {
    enable = true;
    setSocketVariable = true;
  };
};

security.wrappers = lib.mkIf withDocker {
  docker-rootlesskit = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_bind_service+ep";
    source = "${pkgs.rootlesskit}/bin/rootlesskit";
  };
};
```

**This PR adds:** Add `smriti` user to `docker` group

```nix
users.users.smriti = {
  # ...existing config...
  extraGroups = [ "users" ] ++ lib.optionals withDocker [ "docker" ];
};
```

**Why rootless?**
- Runs Docker daemon as non-root user in user namespace
- Container runtime has no privileged access to host
- Aligns with OpenClaw's security model (no privilege escalation)
- VM-compatible (works in QEMU/KVM environments)

#### Phase 2: VM Setup (nixosVM) ✅ (This PR)

**For current VM-based deployment:**

No additional steps needed! Once the NixOS configuration is rebuilt with this change:
1. Docker daemon will start with rootless mode
2. `smriti` user will have access via docker group membership
3. Can immediately use `docker` commands from OpenClaw agents

**Testing:**
```bash
# After rebuild
systemctl --user status docker  # Check Docker daemon
docker ps                       # Verify access
```

#### Phase 3: Future K8s Deployment (Not Yet Implemented)

**When bommalata runs in Kubernetes pods**, will need:

**Socket mounting** in pod spec:
```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: bommalata
    volumeMounts:
    - name: docker-socket
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-socket
    hostPath:
      path: /run/user/1000/docker.sock  # Rootless socket
      type: Socket
```

**Docker CLI in container image:**
Add `docker-client` to the bommalata container image build.

**Note:** This is future work and not required for current VM-based development.

## Alternative: Docker-in-Docker (DinD) - NOT RECOMMENDED

We could use Docker-in-Docker (privileged container running its own Docker daemon), but this is **explicitly rejected** because:

1. ❌ Requires `--privileged` flag (violates unprivileged requirement)
2. ❌ Needs `CAP_SYS_ADMIN` capability (security risk)
3. ❌ Resource overhead (full daemon per container)
4. ❌ Complexity (nested virtualization, storage drivers)
5. ❌ Breaks OpenClaw's security model

**Our approach (rootless socket mount) is superior:**
- ✅ No privileged containers
- ✅ Minimal overhead (just CLI tools)
- ✅ Uses host's existing Docker infrastructure
- ✅ Maintains security boundaries

## Testing Plan

### Manual Testing (After Implementation)
```bash
# 1. Verify Docker is running on host
systemctl --user status docker

# 2. Check socket exists
ls -la /run/user/1000/docker.sock

# 3. Inside OpenClaw container, test Docker access
docker ps
docker version

# 4. Test bommalata Docker build workflow
cd /var/lib/smriti/workspace/projects/bommalata
nix build .#docker-image
docker load < result
docker run -p 8080:8080 bommalata:latest
```

### Automated Testing
- Add GitHub Actions workflow to test Docker builds in CI
- Use `act` (runs GitHub Actions locally) for local testing
- Ensure bommalata's test suite runs in Docker container

## Security Considerations

### Threat Model
- **Threat:** Malicious agent uses Docker to escape container
- **Mitigation:** Rootless Docker runs in user namespace; no root access on host
- **Residual risk:** Agent can consume host resources (disk, CPU) via Docker

### Recommended Safeguards
1. **Resource limits:** Configure Docker daemon with resource constraints
   ```json
   {
     "default-ulimits": {
       "nofile": { "Hard": 64000, "Soft": 64000 },
       "nproc": { "Hard": 2048, "Soft": 2048 }
     }
   }
   ```

2. **Network isolation:** Consider `--network=none` for builds that don't need network

3. **Audit logging:** Enable Docker events logging
   ```bash
   dockerd-rootless --log-level=info
   ```

4. **Storage quotas:** Configure overlay2 storage driver with size limits

## Rollout Strategy

### Feature Branch: `feat/docker-in-openclaw`
1. Create branch off `master`
2. Implement Phase 1 (host Docker setup)
3. Test on nixosEggYoke
4. Commit and push

### Testing on Dev VM
1. Rebuild NixOS configuration
2. Restart OpenClaw container with new socket mount
3. Validate bommalata Docker build workflow
4. Document any issues

### Merge Criteria
- [ ] Docker builds work from OpenClaw agents
- [ ] No privileged containers required
- [ ] Resource limits configured
- [ ] Documentation updated (README, AGENTS.md)
- [ ] Deepak approval

## Open Questions

1. **Kubernetes vs Docker Compose?**
   - How is OpenClaw deployed on nixosEggYoke?
   - Need to know deployment method to determine where socket mount is configured

2. **Storage Driver?**
   - What storage driver is Docker using? (overlay2 recommended)
   - Check: `docker info | grep "Storage Driver"`

3. **IPv6 Networking?**
   - Rootless Docker sometimes has IPv6 issues in WSL2
   - May need `--ipv6=false` in daemon config

4. **Build Cache Location?**
   - Where should Docker build cache persist?
   - Consider mounting `/var/lib/docker` or using named volume

## References

- [Docker Rootless Mode](https://docs.docker.com/engine/security/rootless/)
- [NixOS Docker Options](https://search.nixos.org/options?query=virtualisation.docker)
- [WSL2 Docker Best Practices](https://docs.docker.com/desktop/wsl/)
- [Docker-in-Docker Considered Harmful](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)

## Appendix: Alternative Approaches Considered

### A. Podman Instead of Docker
**Pros:** Daemonless, rootless by default, drop-in Docker replacement  
**Cons:** Compatibility issues with some Docker images, less ecosystem tooling  
**Decision:** Stick with Docker for now; can revisit if rootless Docker proves insufficient

### B. Nix-based Container Builds Only
**Pros:** No Docker daemon needed, pure Nix builds  
**Cons:** Breaks compatibility with standard Dockerfiles, limits bommalata's portability  
**Decision:** Support both (Nix builds AND Docker) for maximum flexibility

### C. Cloud-based Docker Builds
**Pros:** Offload to cloud (AWS CodeBuild, etc.), no local daemon  
**Cons:** Latency, cost, requires network access, defeats local-first philosophy  
**Decision:** Keep builds local for iteration speed and offline capability
