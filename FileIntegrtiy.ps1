#add your baseline file location
#add your folder location﻿
Write-Host ""
Write-Host "what would you like to do?"
Write-Host ""
Write-Host "       A)Collect new Baseline?"
Write-Host "       B)Begin monitoring files with saved Baseline?"
Write-Host ""

$response=Read-Host -Prompt "Please enter 'A' or 'B' "
Write-Host ""

Function Calculate-File-Hash($filepath){
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-IF-Exists() {
$baselineExists=Test-Path -Path C:\Users\Deepak\Desktop\files\baseline.txt #add your baseline file location

    if($baselineExists){
        #Delete it
        Remove-Item -Path  C:\Users\Deepak\Desktop\files\baseline.txt #add your baseline file location
    }

}

if ($response -eq "A".ToUpper()){
    #Delete Baseline.txt if exist
    Erase-Baseline-IF-Exists
    
    #Calculate Hash from the target files and store in baseline.txt

    #Collect all files in the target folder
    $files = Get-ChildItem -Path .\new

    #For file, calculate the hash and write to baseline.txt
    foreach ($f in $files){
        $hash=Calculate-File-Hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath  .\baseline.txt -Append
    }


}
elseif ($response -eq "B".ToUpper()){
    $fileHashDictionary=@{}
    #Load filehash from baseline.txt and store them in a dictionary
    $filePathAndHashes =Get-Content -Path  C:\Users\Deepak\Desktop\files\baseline.txt #add your baseline file location
    foreach ($f in $filePathAndHashes){
         $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }
    #Begin Monitoring files with saved Baseline
    while($true){
        Start-Sleep -Seconds 1
        $files = Get-ChildItem -Path C:\Users\Deepak\Desktop\files\new #add your folder file location


    #For the file, calculate the hash and write to baseline.txt
    foreach ($f in $files){
        $hash=Calculate-File-Hash $f.FullName
        #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath  C:\Users\Deepak\Desktop\files\baseline.txt -Append
        
        #Notify if a new file hash has been created
        if($fileHashDictionary[$hash.Path] -eq $null){
            # A file has been created! Notify the user
            Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
        }else{
            if($fileHashDictionary[$hash.Path] -eq $hash.Hash){
            #the file is not changed
        }
        else{
            Write-Host "$($hash.Path) has been changed " -ForegroundColor Red
        }
   
    }
    }
 foreach ($key in $fileHashDictionary.Keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists) {
                # One of the baseline files must have been deleted, notify the user
                Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray
            }
        }
    }
}


