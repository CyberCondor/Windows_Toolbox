param(
    [Parameter(mandatory=$True, Position=0, ValueFromPipeline=$false)]
    [AllowEmptyString()]
    [system.String]$ProcessName
)

$Process       = Get-Process | where{$_.Name -like "*$($ProcessName)*"}
$ParentProcess = Get-CimInstance -ClassName Win32_Process | where{$_.Name -like "*$($ProcessName)*"} | select ProcessId,CommandLine,ParentProcessId
$Service       = Get-CimInstance -ClassName win32_service

foreach($ID in $Process){
    foreach($ParentID in $ParentProcess){
        if($ID.Id -eq $ParentID.ProcessId){
            $ID | Add-Member -NotePropertyMembers @{ParentId=$ParentID.ParentProcessId;CommandLine=$ParentID.CommandLine}
            break
        }
    }
}

$TargetProcess = [System.Collections.Generic.List[PSObject]]::New()

if($Process){
    $Count = 0

    foreach($Target in $Process){
        $Parent = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId like '$($Target.ParentId)'"
        $TargetProcess.Add([pscustomobject]@{Name          =$Target.Name;
                                             Id            =$Target.Id;
                                             ParentId      =$Target.ParentId;
                                             ParentName    =$Parent.Name
                                             ParentPath    =$Parent.ExecutablePath
                                             SId           =$Target.SI;
                                             Handles       =$Target.Handles;
                                             Threads       =$Target.Threads;
                                             Path          =($Target.Path -replace "`"","");
                                             CommandLine   =$Target.CommandLine
                                             FileVersion   =$Target.FileVersion;
                                             ProductVersion=$Target.ProductVersion;
                                             Product       =$Target.Product;
                                             Company       =$Target.Company;
                                             Description   =$Target.Description;
                                             Svc_Name      =$null;
                                             Svc_ProcessId =$null;
                                             Svc_StartMode =$null;
                                             Svc_State     =$null;
                                             Svc_Status    =$null;
                                             Svc_PathName  =$null;
                                             Svc_Version   =$null})
        foreach($Sv in $Service){
            if($Sv.ProcessId -eq $Target.Id){
                $TargetProcess[$Count].Svc_Name      =$Sv.Name
                $TargetProcess[$Count].Svc_ProcessId =$Sv.ProcessId
                $TargetProcess[$Count].Svc_StartMode =$Sv.StartMode
                $TargetProcess[$Count].Svc_State     =$Sv.State
                $TargetProcess[$Count].Svc_Status    =$Sv.Status
                $TargetProcess[$Count].Svc_PathName  =($Sv.PathName -replace "`"","")
                $TargetProcess[$Count].Svc_Version   =$(Try{((Get-Item $(($Sv.PathName) -replace "`"","") -ErrorAction Stop).VersionInfo.ProductVersion)}Catch{Write-Output "Service '$($Sv.Name)'s 'Path Name' contains no version info."})
            }
        }
        $Count++
    }

    $TargetProcess | Sort SId,Company,ProcessId | fl

}else{Write-Output "Process '$($ProcessName)' not found."}
