# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias vm='function _vm() { sshpass -p "password" ssh -X root@192.168.100.$1; }; _vm'
alias vi=vim
alias ll='ls -lh --group-directories-first'
alias virsh='sudo virsh'
alias ap=ansible-playbook
alias cockpit_sshfs='sshfs -d -o allow_root,auto_unmount root@192.168.100.80:/root/cockpit-ovirt/dashboard cockpit-remote-sshfs/'
alias hco_sshfs='sshfs -d -o allow_root,auto_unmount root@10.35.0.115:/root/go/src/github.com/kubevirt/hyperconverged-cluster-operator /home/irosenzw/go/src/github.com/kubevirt/hyperconverged-cluster-operator'
alias gsync=git_sync
alias gfr='git fetch; git rebase'
alias postman='Postman'
alias uilogin='oc login https://api.working.oc4:6443 -u kubeadmin -p $(ssh root@dell-r730-002.dsal.lab.eng.bos.redhat.com cat /root/oc4/working/auth/kubeadmin-password)'
alias bbr=build_bridge
alias st='speedtest'
alias tgb="git branch | grep -i '*' | cut -d' ' -f2"
alias gcan="git commit --amend --no-edit"
alias oclogin="oc login https://api.ostest.test.metalkube.org:6443 -u kubeadmin -p fznPQ-QXyyi-QyzGi-AGnkB"
alias octestlogin="oc login https://api.ostest.test.metalkube.org:6443 -u test -p test"
alias runtest='function _run_test() { STORAGE_CLASS=rook-ceph NO_HEADLESS=true yarn run test-suite  --params.openshift true --specs="integration-tests/tests/base.scenario.ts,packages/kubevirt-plugin/integration-tests/tests/$1"; }; _run_test'
alias listtest='tree --dirsfirst $HOME/console/frontend/packages/kubevirt-plugin/integration-tests/tests'
alias gcf='git diff-tree --no-commit-id --name-only -r HEAD'
alias spk='cat ~/.ssh/id_rsa.pub'
alias pps='cat ~/temp-files/pull-secret'

function build_bridge() {
	cd ~/ui/console
	./builder-run.sh ./build-backend.sh
        scp bin/bridge ido@10.35.0.115:/home/ido/console/bin
	cd -
}

function git_sync() {
	git checkout master
	git fetch upstream master
	git merge upstream/master
	git push
}
set-title(){
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}

export KUBECONFIG=/home/irosenzw/.kube/config
export PATH=$PATH:/home/irosenzw/go/bin:/usr/local/go/bin
export HOT_RELOAD='true'

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/Android/Sdk/platform-tools:$PATH"
export GOPATH="$HOME/go"

export JAVA_HOME=/home/irosenzw/Downloads/android-studio/jre/

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:/home/irosenzw/bin
