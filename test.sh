#!/bin/sh
set -e

RID_ARM="osx-arm64"
RID_INTEL="osx-x64"

function run_netcore() {
	framework=$1
	runtime=$2

	echo "** Running: $framework xplat framework-dependent **"
	./publish/$framework/xplat/fxdependent/msal

	# echo "** Running: $framework xplat self-contained **"
	# ./publish/$framework/xplat/selfcontained/msal

	echo "** Running: $framework $runtime **"
	./publish/$framework/$runtime/full/msal

	echo "** Running: $framework $runtime single-file **"
	./publish/$framework/$runtime/singlefile/msal

	echo "** Running: $framework $runtime single-file + extract-native **"
	./publish/$framework/$runtime/singlefile_extractnative/msal

	echo "** Running: $framework $runtime single-file + extract-all **"
	./publish/$framework/$runtime/singlefile_extractall/msal
}

# .NET 6
run_netcore net6.0 $RID_INTEL

# .NET 5
run_netcore net5.0 $RID_INTEL

# .NET Core 3.1
run_netcore netcoreapp3.1 $RID_INTEL
