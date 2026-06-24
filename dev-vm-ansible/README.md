# dev-vm-ansible

Provisions a fresh UTM Debian VM as a dev server. Run from the Mac.

## Manual prerequisites

1. **Create the VM in UTM**: install Debian, set a **strong root password**,
   create a **`dev`** user with a normal password, and **include the SSH server**
   in the install.
2. **Snapshot**: create a clone of the VM.
3. **Bridged networking**: stop the VM, edit network settings, select
   **bridged networking**, start it, and note the IP shown at login.
   You'll be prompted for this IP when you run the playbook (or pass it with
   `-e vm_ip=<ip>` to skip the prompt).

## Control-node (Mac) prerequisites

- `ansible` (installed via the repo Brewfile).
- `sshpass` for the first password-based run: `brew install sshpass`.
- `~/.ssh/id_ed25519.pub` present (installed into dev's authorized_keys).
- `~/.tmux.conf` present (copied to the VM as-is).
- Ghostty installed (provides the `xterm-ghostty` terminfo for `infocmp`).
- Install collections once: `ansible-galaxy collection install -r requirements.yml`.

## First run (password bootstrap)

```bash
cd dev-vm-ansible
ansible-playbook site.yml --ask-pass -e vm_ip=192.168.65.10
```

Prompts, in order:

- **SSH password** (`--ask-pass`): the `dev` user's login password.
- **VM IP address** (asked once per play, so twice on `site.yml`). Pass
  `-e vm_ip=<ip>` to answer once and suppress both prompts.
- **ROOT password**: for `su` during bootstrap.
- **Sudo password for dev**: for the provision play.

After bootstrap, SSH password auth is disabled (key-only) and `dev` is a sudoer.

## Re-runs (key auth)

```bash
cd dev-vm-ansible
ansible-playbook provision.yml
```

Prompts only for `dev`'s sudo password. Idempotent — safe to run repeatedly.

## Post-run manual steps

1. Add the printed GitHub public key at <https://github.com/settings/keys>.
   `docker run hello-world`.
2. (Optional) In VS Code install **Open Remote - SSH** and connect to the host.

## Usage

```bash
ssh dev@<vm-ip>
tmux new -s <project-name>
```
