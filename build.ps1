$RID = "win-x64"
$CFG = "Debug"

Remove-Item -Recurse -Force ./publish -ErrorAction SilentlyContinue

function Publish-NetCore {
	param (
		[string]$framework,
		[string]$runtime,
		[string]$config
	)

	dotnet publish app -nologo -f $framework `
		-c $config `
		-o ./publish/$framework/xplat/fxdependent

	dotnet publish app -nologo -f $framework `
		-c $config `
		--self-contained `
		-o ./publish/$framework/xplat/selfcontained

	dotnet publish app -nologo -f $framework `
		-c $config `
		--self-contained `
		-r $runtime `
		-o ./publish/$framework/$runtime/full

	dotnet publish app -nologo -f $framework `
		-c $config `
		--self-contained `
		-r $runtime `
		-p:PublishSingleFile=true `
		-o ./publish/$framework/$runtime/singlefile

	dotnet publish app -nologo -f $framework `
		-c $config `
		--self-contained `
		-r $runtime `
		-p:PublishSingleFile=true `
		-p:IncludeNativeLibrariesForSelfExtract=true `
		-o ./publish/$framework/$runtime/singlefile_extractnative

	dotnet publish app -nologo -f $framework `
		-c $config `
		--self-contained `
		-r $runtime `
		-p:PublishSingleFile=true `
		-p:IncludeAllContentForSelfExtract=true `
		-o ./publish/$framework/$runtime/singlefile_extractall
}

function Publish-NetFx {
	param (
		[string]$framework,
		[string]$config
	)

	dotnet publish app -nologo -f $framework -c $config `
		-p:PlatformTarget=anycpu `
		-o ./publish/$framework/anycpu

	dotnet publish app -nologo -f $framework -c $config `
		-p:PlatformTarget=x86 `
		-o ./publish/$framework/x86

	dotnet publish app -nologo -f $framework -c $config `
		-p:PlatformTarget=x64 `
		-o ./publish/$framework/x64

	dotnet publish app -nologo -f $framework -c $config `
		-p:PlatformTarget=anycpu32bitpreferred `
		-o ./publish/$framework/anycpu_prefer32
}

# .NET 6
Publish-NetCore -framework net6.0 -runtime $RID -config $CFG

# .NET 5
Publish-NetCore -framework net5.0 -runtime $RID -config $CFG

# .NET Core 3.1
Publish-NetCore -framework netcoreapp3.1 -runtime $RID -config $CFG

# .NET 4.6.1
Publish-NetFx -framework net461 -config $CFG

# .NET 4.7.2
Publish-NetFx -framework net472 -config $CFG
