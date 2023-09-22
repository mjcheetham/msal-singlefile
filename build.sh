#!/bin/sh
set -e

RID_ARM="osx-arm64"
RID_INTEL="osx-x64"
CFG="Debug"

rm -rf ./publish

function publish_netcore() {
	framework=$1
	runtime=$2
	config=$3

	dotnet publish app -nologo -f $framework \
		-c $config \
		-o ./publish/$framework/xplat/fxdependent

	# dotnet publish app -nologo -f $framework \
	# 	-c $config \
	# 	--self-contained \
	# 	-o ./publish/$framework/xplat/selfcontained

	dotnet publish app -nologo -f $framework \
		-c $config \
		--self-contained \
		-r $runtime \
		-o ./publish/$framework/$runtime/full

	dotnet publish app -nologo -f $framework \
		-c $config \
		--self-contained \
		-r $runtime \
		-p:PublishSingleFile=true \
		-o ./publish/$framework/$runtime/singlefile

	dotnet publish app -nologo -f $framework \
		-c $config \
		--self-contained \
		-r $runtime \
		-p:PublishSingleFile=true \
		-p:IncludeNativeLibrariesForSelfExtract=true \
		-o ./publish/$framework/$runtime/singlefile_extractnative

		dotnet publish app -nologo -f $framework \
		-c $config \
		--self-contained \
		-r $runtime \
		-p:PublishSingleFile=true \
		-p:IncludeAllContentForSelfExtract=true \
		-o ./publish/$framework/$runtime/singlefile_extractall
}


# .NET 6
publish_netcore net6.0 $RID_INTEL $CFG

# .NET 5
publish_netcore net5.0 $RID_INTEL $CFG

# .NET Core 3.1
publish_netcore netcoreapp3.1 $RID_INTEL $CFG
