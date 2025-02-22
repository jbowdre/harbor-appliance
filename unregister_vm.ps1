Param(
    [Parameter(Position=1)]
    [string]$VISERVER,

    [Parameter(Position=2)]
    [string]$VIUSERNAME,

    [Parameter(Position=3)]
    [string]$VIPASSWORD,

    [Parameter(Position=4)]
    [string]$VMNAME
)

Connect-VIServer -Server "$VISERVER" -User "$VIUSERNAME" -Password "$VIPASSWORD"
$vm = Get-VM "$VMNAME"
Remove-VM -VM $vm -DeletePermanently -Confirm:$false
Disconnect-VIServer * -Confirm:$false