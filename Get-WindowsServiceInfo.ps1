param(
    [Parameter(mandatory=$True, Position=0, ValueFromPipeline=$false)]
    [AllowEmptyString()]
    [system.String]$ServiceName
)

$Process       = Get-Process
$ParentProcess = Get-CimInstance -ClassName Win32_Process | select ProcessId,CommandLine,ParentProcessId
$Service       = Get-CimInstance -ClassName win32_service | where{$_.Name -like "*$($ServiceName)*"}

foreach($ID in $Process){
    foreach($ParentID in $ParentProcess){
        if($ID.Id -eq $ParentID.ProcessId){
            $ID | Add-Member -NotePropertyMembers @{ParentId=$ParentID.ParentProcessId;CommandLine=$ParentID.CommandLine}
            break
        }
    }
}

$TargetService = [System.Collections.Generic.List[PSObject]]::New()

if($Service){
    $Count = 0

    foreach($Target in $Service){
        $TargetService.Add([pscustomobject]@{ProcessName   =$null;
                                             ProcessId     =$null;
                                             ParentId      =$null;
                                             ParentName    =$null;
                                             ParentPath    =$null;
                                             SId           =$null;
                                             Handles       =$null;
                                             Threads       =$null;
                                             Path          =$null;
                                             CommandLine   =$null;
                                             FileVersion   =$null;
                                             ProductVersion=$null;
                                             Product       =$null;
                                             Company       =$null;
                                             Description   =$null;
                                             Svc_Name      =$Target.Name;
                                             Svc_ProcessId =$Target.ProcessId;
                                             Svc_StartMode =$Target.StartMode;
                                             Svc_State     =$Target.State;
                                             Svc_Status    =$Target.Status;
                                             Svc_PathName  =($Target.PathName -replace "`"","");
                                             Svc_Version   =$(Try{((Get-Item $(($Target.PathName) -replace "`"","") -ErrorAction Stop).VersionInfo.ProductVersion)}Catch{Write-Output "Service '$($Target.Name)'s 'Path Name' contains no version info."})})
        foreach($Id in $Process){
            if($Target.ProcessId -eq $Id.Id){
                $TargetService[$Count].ProcessName   =$Id.Name;
                $TargetService[$Count].ProcessId     =$Id.Id;
                $TargetService[$Count].ParentId      =$Id.ParentId;
                $TargetService[$Count].ParentName    =$Id.Name
                $TargetService[$Count].ParentPath    =$Id.ExecutablePath
                $TargetService[$Count].SId           =$Id.SI;
                $TargetService[$Count].Handles       =$Id.Handles;
                $TargetService[$Count].Threads       =$Id.Threads;
                $TargetService[$Count].Path          =($Id.Path -replace "`"","");
                $TargetService[$Count].CommandLine   =$Id.CommandLine
                $TargetService[$Count].FileVersion   =$Id.FileVersion;
                $TargetService[$Count].ProductVersion=$Id.ProductVersion;
                $TargetService[$Count].Product       =$Id.Product;
                $TargetService[$Count].Company       =$Id.Company;
                $TargetService[$Count].Description   =$Id.Description;
            }
        }
        $Count++
    }

    $TargetService | Sort SId,Company,ProcessId | fl

}else{Write-Output "Service '$($ServiceName)' not found."}
