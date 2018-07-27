# Reinstall a specific app in stack 
"ReinstallAppInStack.ps1"

$script:IncludeDir = $null
if ( !$script:IncludeDir)
{
    # Log-Date can't be used yet as Framework has not been loaded

	Write-Host "Initialising environment - presumed not running through RemotePS"
	$MyInvocation.MyCommand.Path
	$script:IncludeDir = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..\scripts'
    Write-Host "Include path $script:IncludeDir"
	. "$script:IncludeDir\Init-Baking-Vars.ps1"
	. "$script:IncludeDir\Init-Baking-Includes.ps1"
}
else
{
	Write-Output "$(Log-Date) Environment already initialised" | Out-Host
}

$a = Get-Date
Write-Host "$($a.ToLocalTime()) Local Time"
Write-Host "$($a.ToUniversalTime()) UTC"

try {
    $Region = 'us-east-1'

    $Stack = 10
    $App = 3

    & (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "SuspendStack.ps1") -Stack $Stack
    
    Write-GreenOutput( "Re-installing Application $App in stack $stack") | Out-Host
    Write-GreenOutput( "If you get the error 'An error occurred (ValidationError) when calling the UpdateStack operation: No updates are to be performed.', its because the previous application updated in this stack is the same one - there are no changes.") | Out-Host

    aws cloudformation update-stack --stack-name eval$($stack) --region us-east-1 --capabilities CAPABILITY_IAM --use-previous-template `
    --parameters ParameterKey=03ApplCount,UsePreviousValue=true ParameterKey=03DBUsername,UsePreviousValue=true ParameterKey=04DBPassword,UsePreviousValue=true ParameterKey=05WebUser,UsePreviousValue=true ParameterKey=06WebPassword,UsePreviousValue=true ParameterKey=07KeyName,UsePreviousValue=true ParameterKey=08RemoteAccessLocation,UsePreviousValue=true ParameterKey=10LansaGitRepoBranch,UsePreviousValue=true ParameterKey=11WebServerInstanceTyp,UsePreviousValue=true ParameterKey=12WebServerMaxConnec,UsePreviousValue=true ParameterKey=13DBInstanceClass,UsePreviousValue=true ParameterKey=14DBName,UsePreviousValue=true ParameterKey=15DBEngine,UsePreviousValue=true ParameterKey=18WebServerCapacity,UsePreviousValue=true ParameterKey=19DBAllocatedStorage,UsePreviousValue=true ParameterKey=20DBIops,UsePreviousValue=true ParameterKey=DomainName,UsePreviousValue=true ParameterKey=DomainPrefix,UsePreviousValue=true ParameterKey=StackNumber,UsePreviousValue=true ParameterKey=WebServerGitRepo,UsePreviousValue=true `
    ParameterKey=22AppToReinstall,UsePreviousValue=false,ParameterValue=$App `
    ParameterKey=22TriggerAppReinstall,UsePreviousValue=false,ParameterValue=$App `
    ParameterKey=22TriggerAppUpdate,UsePreviousValue=true ParameterKey=22TriggerCakeUpdate,UsePreviousValue=true ParameterKey=23TriggerChefUpdate,UsePreviousValue=true ParameterKey=24TriggerWinUpdate,UsePreviousValue=true ParameterKey=25TriggerWebConfig,UsePreviousValue=true ParameterKey=26TriggerIcingUpdate,UsePreviousValue=true ParameterKey=01LansaMSI,UsePreviousValue=true ParameterKey=02LansaMSIBitness,UsePreviousValue=true ParameterKey=03ApplMSIuri,UsePreviousValue=true ParameterKey=17UserScriptHook,UsePreviousValue=true ParameterKey=19HostRoutePortNumber,UsePreviousValue=true ParameterKey=19HTTPPortNumber,UsePreviousValue=true ParameterKey=19HTTPPortNumberHub,UsePreviousValue=true ParameterKey=19JSMAdminPortNumber,UsePreviousValue=true ParameterKey=19JSMPortNumber,UsePreviousValue=true ParameterKey=21ELBTimeout,UsePreviousValue=true ParameterKey=27TriggerPatchInstall,UsePreviousValue=true ParameterKey=28PatchBucketName,UsePreviousValue=true ParameterKey=29PatchFolderName,UsePreviousValue=true ParameterKey=SSLCertificateARN,UsePreviousValue=true
    Write-Output( "*********************************************")

    Write-Output( "Waiting up to 10 minutes for stack eval$($stack) to complete updating")
    Wait-CFNStack -StackName "eval$($stack)" -region 'us-east-1' -Status 'UPDATE_COMPLETE' -Timeout 600        

} catch {
    $_
}