# standalone

# なにこれ
powercli の練習キット

# 使い方
同梱の docker-compose.yml で実行環境構築  
```sh 
$ docker-compose up -d 
$ docker-compose run --rm pwsh スクリプト
```

# 実行例
```sh
$ docker-compose up -d
Creating esxi ... done

$ docker-compose run --rm pwsh invoke.ps1 vm1 -user u -password p
Creating invoke-vm_pwsh_run ... done
WARNING: Please consider joining the VMware Customer Experience Improvement Program, so you can help us make PowerCLI a better product. You can join using the following command:

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true

VMware's Customer Experience Improvement Program ("CEIP") provides VMware with information that enables VMware to improve its products and services, to fix problems, and to advise you on how best to deploy and use our products.  As part of the CEIP, VMware collects technical information about your organization’s use of VMware products and services on a regular basis in association with your organization’s VMware license key(s).  This information does not personally identify any individual.

For more details: type "help about_ceip" to see the related help article.

To disable this warning and set your preference use the following command and restart PowerShell: 
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true or $false.

Name                           Port  User
----                           ----  ----
esxi                           443   u

Name : DC0_H0_VM0


Name : DC0_H0_VM1


Name : DC0_C0_RP0_VM0


Name : DC0_C0_RP0_VM1

debug
continue: False
pswdmaster: pswdmaster.txt.example
cmdset: cmd.d/default
is_list: False
result_dir: result.d/vm1
logname: result.d/vm1/20220422.log
user: u
password: p
```

# 既知のバグ
