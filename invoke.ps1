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
function mkpswdlist{
    param($pswdmaster)
    $pswdlist = @()
    foreach ($line in $(get-content $pswdmaster | select-string -pattern "^//" -notmatch)){
        $buf = @{}
        $buf += ConvertFrom-StringData("vm="+ $line.line.split("`t")[0])
        $buf += ConvertFrom-StringData("user="+ $line.line.split("`t")[1])
        $buf += ConvertFrom-StringData("password="+ $line.line.split("`t")[2])
        $pswdlist += $buf
    }
    return $($(convertto-json $pswdlist) | convertfrom-json)
}

function invoker{
    param($vm, $cmd, $pswdlist)

    # get credential
    try{
        $pswd = $pswdlist.where({$_.vm -eq $vm})
    }catch{
        try{
            $pswd = $pswdlist.where({$_.vm -eq "default"})
        }catch{
            write-output "missing password error"
            exit;
        }
    }

    # invoke command
    try{
        invoke-vmscript -vm $vm -scripttext $(get-content $cmd -raw) -guestuser $pswd.user -guestpassword $pswd.password
    }catch{
        $_.Exception.Message
    }
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
}else{
    $pswdlist = mkpswdlist -pswdmaster $pswdmaster
}

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

# Import-Module VMware.VimAutomation.Core

if (-not [string]::IsNullOrEmpty($credential)){
    Connect-VIServer -Server $viserver -Credential $credential -Force
}else{
    if (([string]::IsNullOrEmpty($viuser)) -or ([string]::IsNullOrEmpty($vipassword))){
        $viuser = read-host "viUser"
        $vipassword = read-host "viPassword"
    }
    Connect-VIServer -Server $viserver -User $viuser -Password $vipassword -Force
}

## connected VIServer

if ( -not $is_list ){
    $lists = @($target)
}else{
    $lists = get-content $list
}

# list > cmd 
foreach ($vm in $lists){
    foreach ($cmd in (get-childitem $cmdset -exclude "@*")){
        echo "$vm $cmd"
        try{
            $vmspec = get-vm $vm
            # call invoker
            invoker -vm $vm -cmd $cmd -pswdlist $pswdlist
        }catch{
            $_.Exception.Message
        }
    }
}


## end of connection
Disconnect-VIServer -Server $viserver -Confirm:$false
