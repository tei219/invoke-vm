#Import-Module VMware.VimAutomation.Core

# invoke.ps1 target|list [cmdset] [viserver] [user] [password] [credential] [pswdmaster] [continue]
Param( 
    [string]$target,
    [string]$cmdset = "default",
    [string]$viserver = "esxi",
    [string]$user ,
    [string]$password ,
    $credential ,
    [string]$pswdmaster = "pswdmaster.txt.example",
    [boolean]$continue = $false
    )

foreach ($dirname in ("list.d","result.d","cmd.d")){
    if(-not (test-path $dirname)){
        mkdir $dirname
    }
}

if ( -not ( test-path $pswdmaster)){
    write-output "missing password master file: $pswdmaster, create it."
    exit
}

if (-not (test-path $cmdset) ) {
    if (test-path "cmd.d/$cmdset"){
        $cmdset = join-path "cmd.d" $cmdset
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
    $result_dir = join-path "result.d" $(Split-Path $target -Leafbase)
}else{
    if (test-path "list.d/$target"){
        $is_list = $true
        $result_dir = join-path "result.d" $(Split-Path "list.d/$target" -Leafbase)
    }else{
        $is_list = $false
        $result_dir = join-path "result.d" $target
    }
}

# set logname
$logname = join-path $result_dir "$ymd.log"


if (-not [string]::IsNullOrEmpty($credential)){
    Connect-VIServer -Server $viserver -Credential $credential -Force
}else{
    if (([string]::IsNullOrEmpty($user)) -or ([string]::IsNullOrEmpty($password))){
        $user = read-host "User"
        $password = read-host "Password"
    }
    Connect-VIServer -Server $viserver -User $user -Password $password -Force
}

## connected VIServer

get-vm | select name


## end of connection
Disconnect-VIServer -Server $viserver -Confirm:$false






write-output "debug"
write-output "continue: $continue"
write-output "pswdmaster: $pswdmaster"
write-output "cmdset: $cmdset"
write-output "is_list: $is_list"
write-output "result_dir: $result_dir"
write-output "logname: $logname"
write-output "user: $user"
write-output "password: $password"