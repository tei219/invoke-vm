# invoke.ps1 target|list [cmdset] [viserver] [viuser] [vipassword] [credential] [pswdmaster] [continue]
Param( 
    [string]$target,
    [string]$cmdset = "default",
    [string]$viserver = "esxi",
    [string]$viuser ,
    [string]$vipassword ,
    $credential ,
    [string]$pswdmaster = "pswdmaster.txt",
    [boolean]$continue = $false
    )

###############################
function invoker{
    param($vm, $cmd, $pswdmaster)
    write-output "invoker $vm $cmd $pswdmaster"
    $a = $(select-string $pswdmaster -Pattern "^$vm").line.split("`t")
    $a | convertto-json
}
##############################

foreach ($dirname in ("list.d","result.d","cmd.d")){
    if(-not (test-path $dirname)){
        mkdir $dirname
    }
}

if ( -not ( test-path $pswdmaster)){
    write-output "missing password master file: $pswdmaster, create it."
    exit
}
 {"vm": "default", "user": "root", "password": "pass"} | convertto-json

if (-not (test-path $cmdset) ) {
    if (test-path "cmd.d/$cmdset"){
        $cmdset = resolve-path (join-path "cmd.d" $cmdset)
        
    }else{
        write-output "missing command set: $cmdset, create it."
        exit
    }
}

if ([string]::IsNullOrEmpty($target)){
    write-output "target is empty: $target, set it."
    exit
}

# set ymd 
$ymd = (Get-Date).ToString("yyyyMMdd")

# is list?
# set result dir
if ( (test-path $target) ) {
    $is_list = $true
    $list = resolve-path $target
    $result_dir = join-path "result.d" $(Split-Path $target -Leafbase)
}else{
    if (test-path "list.d/$target"){
        $is_list = $true
        $list = resolve-path list.d/$target
        $result_dir = join-path "result.d" $(Split-Path "list.d/$target" -Leafbase)
    }else{
        $is_list = $false
        $result_dir = join-path "result.d" $target
    }
}

# set logname
$logname = join-path $result_dir "$ymd.log"

# set default guestuser/password
#select-pswd -pswdmaster $pswdmaster

# Import-Module VMware.VimAutomation.Core

if (-not [string]::IsNullOrEmpty($credential)){
#    Connect-VIServer -Server $viserver -Credential $credential -Force
}else{
    if (([string]::IsNullOrEmpty($viuser)) -or ([string]::IsNullOrEmpty($vipassword))){
        $viuser = read-host "viUser"
        $vipassword = read-host "viPassword"
    }
#    Connect-VIServer -Server $viserver -User $viuser -Password $vipassword -Force
}

## connected VIServer

# commander#1
if ( -not $is_list ){
    $lists = @($target)
}else{
    $lists = get-content $list
}

#tartget is list
foreach ($vm in $lists){
    foreach ($cmd in (get-childitem $cmdset -exclude "@*")){
        echo "$vm $cmd"
        # call invoker
        invoker -vm $vm -cmd $cmd -pswdmaster $pswdmaster
    }
}


## end of connection
#Disconnect-VIServer -Server $viserver -Confirm:$false
