$RID = "win-x64"
$CFG = "Debug"

function Run-NetCore {
	param (
		[string]$framework,
		[string]$runtime,
		[string]$config
	)

	Write-Output "** Running: $framework xplat framework-dependent **"
	& "./publish/$framework/xplat/fxdependent/msal.exe"

	Write-Output "** Running: $framework xplat self-contained **"
	& "./publish/$framework/xplat/selfcontained/msal.exe"
	
	Write-Output "** Running: $framework $runtime **"
	& "./publish/$framework/$runtime/full/msal.exe"
	
	Write-Output "** Running: $framework $runtime single-file **"
	& "./publish/$framework/$runtime/singlefile/msal.exe"

	Write-Output "** Running: $framework $runtime single-file + extract-native **"
	& "./publish/$framework/$runtime/singlefile_extractnative/msal.exe"

	Write-Output "** Running: $framework $runtime single-file + extract-all **"
	& "./publish/$framework/$runtime/singlefile_extractall/msal.exe"
}

function Run-NetFx {
	param (
		[string]$framework,
		[string]$config
	)

	Write-Output "** Running: $framework anycpu **"
	& "./publish/$framework/anycpu/msal.exe"

	Write-Output "** Running: $framework x86 **"
	& "./publish/$framework/x86/msal.exe"

	Write-Output "** Running: $framework x64 **"
	& "./publish/$framework/x64/msal.exe"

	Write-Output "** Running: $framework anycpu+prefer32 **"
	& "./publish/$framework/anycpu_prefer32/msal.exe"
}

# .NET 6
Run-NetCore -framework net6.0 -runtime $RID -config $CFG

# .NET 5
Run-NetCore -framework net5.0 -runtime $RID -config $CFG

# .NET Core 3.1
Run-NetCore -framework netcoreapp3.1 -runtime $RID -config $CFG

# .NET 4.6.1
Run-NetFx -framework net461 -config $CFG

# .NET 4.7.2
Run-NetFx -framework net472 -config $CFG
