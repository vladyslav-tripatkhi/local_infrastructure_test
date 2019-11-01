import os
import pytest

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


@pytest.mark.parametrize('pkg', ['unzip'])
def test_pkg(host, pkg):
    package = host.package(pkg)
    assert package.is_installed

def test_terraform_file(host):
    f = host.file('/usr/local/bin/terraform')
    print(f)
    assert f.exists

# def test_sshd_inactive(host):
#     assert host.service("sshd").is_running is False
