@echo off
title DNS Changer v1 (By Parhamray)


:: Checking for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

:: Check if PowerShell is available
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: PowerShell is not installed or not in the PATH.
    echo Please install PowerShell to use this script.
    pause
    exit /b 1
)

:: Determining active Network interface, excluding Virtual ones.
for /f "tokens=* delims=" %%a in ('powershell -NoProfile -Command "Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and ($_.Name -match 'Wi-Fi|WiFi|Ethernet|Wireless|WLAN|LAN') -and ($_.InterfaceDescription -notmatch 'Virtual|VPN|TAP|TUN|Tunnel')} | Select-Object -First 1 -ExpandProperty Name"') do set "InterfaceName=%%a"

if "%InterfaceName%"=="" (
    color 0C
    echo ===================================
    echo       No active network found!     
    echo ===================================
    pause
    exit /b
)

:menu
set "origin=main"
cls
color 0B
echo ====================================
echo            DNS CHANGER              
echo ====================================
echo Current Active Network: %InterfaceName%
echo ====================================
echo [1] Automatic DNS      - Resets to default ISP-assigned DNS
echo [2] Cloudflare DNS     - Privacy-focused, fast
echo [3] Adguard DNS        - Blocks ads and trackers
echo [4] Electro DNS        - Bypass gaming sanctions in certain regions, only IPv4
echo [5] European DNS       - European public dns, privacy and security focused, Gdpr compliant.
echo [6] Quad9 DNS          - Security-focused, malware blocking
echo [7] ControlD DNS       - Customizable, also blocks ads and trackers
echo [8] Google DNS         - Reliable, widely used
echo ------------------------------------
echo [9] Show Current DNS
echo [10] Flush DNS Cache
echo [11] Enter Custom DNS
echo [12] Ping All
echo [13] Exit
echo ====================================
set /p choice="Enter your choice (1-13): "

if "%choice%"=="1" goto auto
if "%choice%"=="2" (
	set "dnsprovider=Cloudflare"
	set "ipv4p=1.1.1.1"
	set "ipv4s=1.0.0.1"
	set "ipv6p=2606:4700:4700::1111"
	set "ipv6s=2606:4700:4700::1001"
	goto applydns
	)
if "%choice%"=="3" (
	set "dnsprovider=Adguard"
	set "ipv4p=94.140.14.14"
	set "ipv4s=94.140.15.15"
	set "ipv6p=2a10:50c0::ad1:ff"
	set "ipv6s=2a10:50c0::ad2:ff"
	goto applydns
	)
if "%choice%"=="4" (
	set "dnsprovider=Electro"
	set "ipv4p=78.157.42.100"
	set "ipv4s=78.157.42.101"
	set "ipv6p="
	set "ipv6s="
	goto applydns
	)
if "%choice%"=="5" (
	set "dnsprovider=European"
	set "ipv4p=193.110.81.0"
	set "ipv4s=185.253.5.0"
	set "ipv6p=2a0f:fc80::"
	set "ipv6s=2a0f:fc81::"
	goto applydns
	)
if "%choice%"=="6" (
	set "dnsprovider=Quad9"
	set "ipv4p=9.9.9.9"
	set "ipv4s=149.112.112.112"
	set "ipv6p=2620:fe::fe"
	set "ipv6s=2620:fe::9"
	goto applydns
	)
if "%choice%"=="7" (
	set "dnsprovider=ControlD"
	set "ipv4p=76.76.2.2"
	set "ipv4s=76.76.10.2"
	set "ipv6p=2606:1a40::2"
	set "ipv6s=2606:1a40:1::2"
	goto applydns
	)
if "%choice%"=="8" (
	set "dnsprovider=Google"
	set "ipv4p=8.8.8.8"
	set "ipv4s=8.8.4.4"
	set "ipv6p=2001:4860:4860::8888"
	set "ipv6s=2001:4860:4860::8844"
	goto applydns
	)
if "%choice%"=="9" goto show
if "%choice%"=="10" (
    set "origin=main10"
    goto flush
)
if "%choice%"=="11" goto customdns
if "%choice%"=="12" goto pingservers
if "%choice%"=="13" exit

:: Invalid Input error
cls
color 0C
echo Invalid choice! Please select a valid option.
pause
goto menu

:auto
Powershell -NoProfile -Command "Set-DnsClientServerAddress -InterfaceAlias '%InterfaceName%' -ResetServerAddresses"
cls
color 0A
echo DNS set to Automatic (Default ISP-assigned DNS)
goto flush

:applydns
Powershell -NoProfile -Command "Set-DnsClientServerAddress -InterfaceAlias '%InterfaceName%' -ServerAddresses '%ipv4p%','%ipv4s%'"
Powershell -NoProfile -Command "Set-DnsClientServerAddress -InterfaceAlias '%InterfaceName%' -ServerAddresses '%ipv6p%','%ipv6s%'"
cls
color 0A
echo DNS successfully changed to %dnsprovider% (%ipv4p% / %ipv4s%) - (%ipv6p% / %ipv6s%)
goto flush

:show
cls
color 0E
echo Your current DNS config.
Powershell -NoProfile -Command "Get-DnsClientServerAddress -InterfaceAlias '%InterfaceName%' | Format-Table -AutoSize"
echo.
pause
goto menu

:flush
if "%origin%"=="main10" (
	cls
) else (
	echo.
)
color 0A
ipconfig /flushdns >null
echo DNS cache successfully flushed.
echo.
pause
goto menu

:customdns
cls
color 0B

:ipv4input
echo Enter primary and secondary DNS for IPv4.
set /p "ipv4p=Enter primary IPv4 DNS: "
set /p "ipv4s=Enter secondary IPv4 DNS: "

:: IPv4 format validation
echo %ipv4p%|findstr /r "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo.
    echo -Invalid IPv4 format for primary DNS. Please try again.
    echo.
    goto ipv4input
)
echo %ipv4s%|findstr /r "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo.
    echo -Invalid IPv4 format for secondary DNS. Please try again.
    echo.
    goto ipv4input
)

:ipv6input
echo.
echo Enter primary and secondary DNS for IPv6. (You Can Skip These By Pressing Enter)
set /p "ipv6p=Enter primary IPv6 DNS: "
set /p "ipv6s=Enter secondary IPv6 DNS: "

:: Applying DNS provided by user, and showing the results
goto applydns


:Pingservers
cls
setlocal

:: Define DNS servers to test
if "%~1" neq "" (
    set "dnsServers=%*"
) else (
    set "dnsServers=1.1.1.1 94.140.14.14 78.157.42.100 193.110.81.0 9.9.9.9 76.76.2.2 8.8.8.8"
)

:: Feedback before pinging
echo Pinging the DNS servers... it may take a while.
echo.

:: Call PowerShell to execute the ping, sorting logic, and visual feedback while pinging
powershell -NoProfile -Command ^

    "$ProgressPreference = 'SilentlyContinue'; " ^
    "$dnsServers = '%dnsServers%'.Split(' '); " ^
    "$dnsNames = @{ " ^
    "    '1.1.1.1' = 'Cloudflare DNS'; " ^
    "    '94.140.14.14' = 'Adguard DNS'; " ^
    "    '78.157.42.100' = 'Electro DNS'; " ^
    "    '193.110.81.0' = 'European DNS'; " ^
    "    '9.9.9.9' = 'Quad9 DNS'; " ^
    "    '76.76.2.2' = 'ControlD DNS'; " ^
    "    '8.8.8.8' = 'Google DNS'; " ^
    "}; " ^
    "$results = @(); " ^
    "foreach ($dns in $dnsServers) { " ^
    "    $dnsName = $dnsNames[$dns]; " ^
    "    Write-Host \"Pinging $dns ($dnsName)...\" -ForegroundColor Yellow; " ^
    "    try { " ^
    "        $ping = Test-Connection -ComputerName $dns -Count 4 -ErrorAction Stop; " ^
    "        $avgTime = ($ping | Measure-Object ResponseTime -Average).Average; " ^
    "        $results += [PSCustomObject]@{Server=$dns; Name=$dnsName; Latency=[math]::Round($avgTime, 2)}; " ^
    "    } catch { " ^
    "        $results += [PSCustomObject]@{Server=$dns; Name=$dnsName; Latency='Timeout'}; " ^
    "    } " ^
    "}; " ^
    "$sortedResults = $results | Sort-Object Latency; " ^
    "cls; " ^
    "Write-Host 'Results (Lowest Latency First):' -ForegroundColor Cyan; " ^
    "$sortedResults | Format-Table -AutoSize;"

endlocal

pause
goto menu
