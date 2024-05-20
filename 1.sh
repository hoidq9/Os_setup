REPO_DIR="$(dirname "$(readlink -m "${0}")")"

commands() {
    cd "$REPO_DIR/system" || return
    cp rmkernel /usr/bin && chmod +x /usr/bin/rmkernel
}
epel() {
    if ! rpm -q epel-release; then
        dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
    fi
}
gnome() {
    dnf upgrade -y
    dnf install gnome-shell zsh git gnome-terminal gnome-terminal-nautilus nautilus gnome-disk-utility chrome-gnome-shell PackageKit-command-not-found gnome-software gnome-system-monitor gdm git dbus-x11 gcc gdb ibus-m17n jq -y
}
kernel() {
    yum install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm -y
    yum --enablerepo=elrepo-kernel install kernel-ml -y
}
shell() {
    chsh -s /bin/zsh $1
}
commands
find "$REPO_DIR" -type f -print0 | xargs -0 dos2unix --
epel
gnome
kernel
shell $1
grep -q "clean_requirements_on_remove=1" /etc/dnf/dnf.conf || echo -e "directive clean_requirements_on_remove=1" >>/etc/dnf/dnf.conf
systemctl set-default graphical.target
