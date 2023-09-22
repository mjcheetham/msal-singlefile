using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using Microsoft.Identity.Client;
using Microsoft.Identity.Client.Broker;
using static Native;

internal static class Native
{
    public const int GA_ROOTOWNER = 3;
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern IntPtr GetAncestor(IntPtr hwnd, int flags);
}


public static class Program
{
    public static async Task Main(string[] args)
    {
        Console.WriteLine("========================================================");
        Console.WriteLine("Framwork/OS    | {0}", GetTarget());
        Console.WriteLine("--------------------------------------------------------");
        Console.WriteLine("Original       | {0}", Try(() => GetExecutingAssemblyDirectory_Base()));
        Console.WriteLine("Candidate      | {0}", Try(() => GetExecutingAssemblyDirectory_New()));
        Console.WriteLine("--------------------------------------------------------");
        Console.WriteLine("AppCxt.BaseDir | {0}", Try(() => AppContext.BaseDirectory));
        Console.WriteLine("Asm.Location   | {0}", Try(() => Assembly.GetExecutingAssembly().Location));
        Console.WriteLine("Asm.CodeBase   | {0}", Try(() => Assembly.GetExecutingAssembly().CodeBase));
        Console.WriteLine("========================================================");
        Console.WriteLine();

        if (args.Any(x => StringComparer.OrdinalIgnoreCase.Equals(x, "--wam")))
            await TestWindowsBrokerAsync();
    }

    static string GetTarget()
    {
#if NETFRAMEWORK
        return $".NET Framework {Environment.Version} (Windows)";
#else
        string os = "Unknown";

        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            os = "Windows";
        else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            os = "macOS";
        else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            os = "Linux";

        return $"{AppContext.TargetFrameworkName} ({os})";
#endif
    }

    static string Try(Func<string> fn)
    {
        try
        {
            string val = fn();
            if (val is null) return "(null)";
            return $"\"{val}\"";
        }
        catch { return "(failed)"; }
    }

    static string GetExecutingAssemblyDirectory_Base()
    {
        var managedPath = Assembly.GetExecutingAssembly().CodeBase;
        if (managedPath == null)
        {
            managedPath = Assembly.GetExecutingAssembly().Location;
        }
        else if (managedPath.StartsWith("file:///"))
        {
            managedPath = managedPath.Substring(8).Replace('/', '\\');
        }
        else if (managedPath.StartsWith("file://"))
        {
            managedPath = @"\\" + managedPath.Substring(7).Replace('/', '\\');
        }

        managedPath = Path.GetDirectoryName(managedPath);
        return managedPath;
    }

    static string GetExecutingAssemblyDirectory_New()
    {
        // In .NET 5 and later, for bundled assemblies, the value returned
        // by Assembly::Location is the empty string. In that case we should
        // look at the AppContext.BaseDirectory property that points to the
        // containing directory of the host executable when bundled.
        var managedPath = Assembly.GetExecutingAssembly().Location;
        if (string.IsNullOrWhiteSpace(managedPath))
        {
            return AppContext.BaseDirectory;
        }
        else
        {
            return Path.GetDirectoryName(managedPath);
        }
    }

    static async Task TestWindowsBrokerAsync()
    {
        string clientId = "6afec070-b576-4a2f-8d95-41f317b28e06";
        string[] scopes = { "user.read" };

        IntPtr consoleHandle = GetConsoleWindow();
        IntPtr parentHandle = GetAncestor(consoleHandle, GA_ROOTOWNER);

        var brokerOptions = new BrokerOptions(BrokerOptions.OperatingSystems.Windows);

        var app = PublicClientApplicationBuilder.Create(clientId)
            .WithBroker(brokerOptions)
            .WithParentActivityOrWindow(() => parentHandle)
            .Build();

        var result = await app.AcquireTokenInteractive(scopes).ExecuteAsync();

        Console.WriteLine(result.AccessToken);
    }
}
